//
//  StreamingTextWithCitationsView.swift
//  Deen Buddy Advanced
//
//  Streams text character by character and inserts citation cards at the right positions
//

import SwiftUI

struct StreamingTextWithCitationsView: View {
    let fullText: String
    let citations: [Citation]
    let isStreaming: Bool
    var onTextUpdate: ((String) -> Void)? = nil
    var onStreamingComplete: (() -> Void)? = nil
    var onCitationTap: ((Citation) -> Void)? = nil
    var initialDelay: Double = 0.0

    @Environment(\.colorScheme) var colorScheme
    @State private var displayedCharacterCount: Int = 0
    @State private var streamingTask: Task<Void, Never>? = nil

    // Parsed structure: positions where citations should appear
    private struct CitationPosition {
        let characterIndex: Int  // Position in cleaned text (without markers)
        let citation: Citation
    }

    private var parsedData: (cleanText: String, citationPositions: [CitationPosition]) {
        var cleanText = ""
        var citationPositions: [CitationPosition] = []

        // Pattern to match citation markers: ^[Quran 2:45]
        let pattern = #"\^\[([^\]]+)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (fullText, [])
        }

        let nsString = fullText as NSString
        let matches = regex.matches(in: fullText, options: [], range: NSRange(location: 0, length: nsString.length))

        // Build citation map (handle duplicates by keeping first occurrence)
        var citationMap: [String: Citation] = [:]
        for citation in citations {
            if citationMap[citation.ref] == nil {
                citationMap[citation.ref] = citation
            }
        }

        var lastEnd = 0
        var currentCleanPosition = 0

        for match in matches {
            // Add text before citation
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let beforeText = nsString.substring(with: beforeRange)
                cleanText += beforeText
                currentCleanPosition += beforeText.count
            }

            // Extract citation ref and add to positions
            if let refRange = Range(match.range(at: 1), in: fullText) {
                let ref = String(fullText[refRange])
                if let citation = citationMap[ref] {
                    citationPositions.append(CitationPosition(
                        characterIndex: currentCleanPosition,
                        citation: citation
                    ))
                }
            }

            lastEnd = match.range.location + match.range.length
        }

        // Add remaining text
        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            cleanText += nsString.substring(with: remainingRange)
        }

        return (cleanText, citationPositions)
    }

    // Animation speed
    private let characterDelay: Double = 0.05

    var body: some View {
        let parsed = parsedData

        // Build the view with streamed text + citation cards
        buildContentView(cleanText: parsed.cleanText, citationPositions: parsed.citationPositions)
            .onAppear {
                if isStreaming {
                    startStreaming(cleanText: parsed.cleanText)
                } else {
                    displayedCharacterCount = parsed.cleanText.count
                }
            }
            .onChange(of: isStreaming) { streaming in
                if !streaming {
                    streamingTask?.cancel()
                    streamingTask = nil
                }
            }
            .onDisappear {
                streamingTask?.cancel()
            }
    }

    private func buildContentView(cleanText: String, citationPositions: [CitationPosition]) -> some View {
        // Create view with text chunks and citation cards
        let displayedText = String(cleanText.prefix(displayedCharacterCount))

        // Determine which citations should be visible
        let visibleCitations = citationPositions.filter { $0.characterIndex <= displayedCharacterCount }

        // Build segments (text chunks and citations)
        let segments = buildSegments(displayedText: displayedText, visibleCitations: visibleCitations)

        // Render using FlowLayout (minimal spacing since words include their own spaces)
        return FlowLayout(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                if let text = segment.text, !text.isEmpty {
                    Text(text)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(.primary)
                } else if let citation = segment.citation {
                    Button(action: {
                        onCitationTap?(citation)
                    }) {
                        HStack(spacing: 6) {
                            // Book icon
                            Image(systemName: AppStrings.chat.citationIconName)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppColors.Chat.citationCardIcon(for: colorScheme))

                            // Citation text
                            Text("\(citation.surah) \(citation.ayah)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.Chat.citationCardText(for: colorScheme))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(AppColors.Chat.citationCardBackground(for: colorScheme))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private struct Segment {
        let text: String?
        let citation: Citation?
    }

    private func buildSegments(displayedText: String, visibleCitations: [CitationPosition]) -> [Segment] {
        var segments: [Segment] = []
        var lastIndex = 0

        for citationPos in visibleCitations {
            // Add text before citation, split by words for better wrapping
            if citationPos.characterIndex > lastIndex {
                let startIdx = displayedText.index(displayedText.startIndex, offsetBy: lastIndex)
                let endIdx = displayedText.index(displayedText.startIndex, offsetBy: citationPos.characterIndex)
                let textSegment = String(displayedText[startIdx..<endIdx])

                // Split text into words to allow proper wrapping
                let words = textSegment.components(separatedBy: " ")
                for (index, word) in words.enumerated() {
                    if !word.isEmpty {
                        // Add space before word (except first word)
                        let wordWithSpace = index > 0 ? " \(word)" : word
                        segments.append(Segment(text: wordWithSpace, citation: nil))
                    } else if index < words.count - 1 {
                        // Empty string means there was a space, preserve it
                        segments.append(Segment(text: " ", citation: nil))
                    }
                }
            }

            // Add space before citation card
            segments.append(Segment(text: " ", citation: nil))

            // Add citation card
            segments.append(Segment(text: nil, citation: citationPos.citation))
            lastIndex = citationPos.characterIndex
        }

        // Add remaining text
        if lastIndex < displayedText.count {
            let startIdx = displayedText.index(displayedText.startIndex, offsetBy: lastIndex)
            let remainingText = String(displayedText[startIdx...])

            // Split remaining text into words
            let words = remainingText.components(separatedBy: " ")
            for (index, word) in words.enumerated() {
                if !word.isEmpty {
                    let wordWithSpace = index > 0 ? " \(word)" : word
                    segments.append(Segment(text: wordWithSpace, citation: nil))
                } else if index < words.count - 1 {
                    segments.append(Segment(text: " ", citation: nil))
                }
            }
        }

        return segments
    }

    private func startStreaming(cleanText: String) {
        guard !cleanText.isEmpty else { return }

        streamingTask?.cancel()
        streamingTask = Task {
            // Initial delay
            if initialDelay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(initialDelay * 1_000_000_000))
            }

            for index in 0..<cleanText.count {
                if Task.isCancelled { break }

                try? await Task.sleep(nanoseconds: UInt64(characterDelay * 1_000_000_000))

                await MainActor.run {
                    displayedCharacterCount = index + 1
                    onTextUpdate?(String(cleanText.prefix(index + 1)))
                }
            }

            if !Task.isCancelled {
                await MainActor.run {
                    onStreamingComplete?()
                }
            }
        }
    }
}
