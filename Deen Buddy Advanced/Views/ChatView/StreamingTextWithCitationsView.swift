//
//  StreamingTextWithCitationsView.swift
//  Deen Buddy Advanced
//
//  Streams text word by word and inserts citation cards at the right positions
//

import SwiftUI

struct StreamingTextWithCitationsView: View {
    let messageId: UUID
    let fullText: String
    let citations: [Citation]
    let isStreaming: Bool
    @ObservedObject var viewModel: ChatViewModel
    var onTextUpdate: ((String) -> Void)? = nil
    var onStreamingComplete: (() -> Void)? = nil
    var onCitationTap: ((Citation) -> Void)? = nil
    var initialDelay: Double = 0.0

    @Environment(\.colorScheme) var colorScheme
    @State private var streamingTask: Task<Void, Never>? = nil

    // Parsed structure: positions where citations should appear
    private struct CitationPosition {
        let wordIndex: Int  // Position in words array (without markers)
        let citation: Citation
    }

    private var parsedData: (words: [String], citationPositions: [CitationPosition]) {
        var words: [String] = []
        var citationPositions: [CitationPosition] = []

        // Pattern to match citation markers: ^[Quran 2:45]
        let pattern = #"\^\[([^\]]+)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            // No citations, just split into words
            return (fullText.split(separator: " ", omittingEmptySubsequences: false).map(String.init), [])
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

        for match in matches {
            // Add text before citation
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let beforeText = nsString.substring(with: beforeRange)

                // Split into words and add to array
                let beforeWords = beforeText.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
                words.append(contentsOf: beforeWords)
            }

            // Extract citation ref and add to positions (citation appears after current words)
            if let refRange = Range(match.range(at: 1), in: fullText) {
                let ref = String(fullText[refRange])
                if let citation = citationMap[ref] {
                    citationPositions.append(CitationPosition(
                        wordIndex: words.count,
                        citation: citation
                    ))
                }
            }

            lastEnd = match.range.location + match.range.length
        }

        // Add remaining text
        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            let remainingText = nsString.substring(with: remainingRange)
            let remainingWords = remainingText.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
            words.append(contentsOf: remainingWords)
        }

        return (words, citationPositions)
    }

    // Animation speed (seconds per word)
    private let wordDelay: Double = 0.08

    var body: some View {
        let parsed = parsedData
        let displayedWordCount = viewModel.getStreamingProgress(for: messageId)

        // Build the view with streamed text + citation cards
        buildContentView(words: parsed.words, citationPositions: parsed.citationPositions, displayedWordCount: displayedWordCount)
            .onAppear {
                if isStreaming {
                    startStreaming(words: parsed.words)
                } else {
                    viewModel.updateStreamingProgress(for: messageId, wordCount: parsed.words.count)
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

    private func buildContentView(words: [String], citationPositions: [CitationPosition], displayedWordCount: Int) -> some View {
        // Get currently displayed words
        let displayedWords = Array(words.prefix(displayedWordCount))

        // Determine which citations should be visible
        let visibleCitations = citationPositions.filter { $0.wordIndex <= displayedWordCount }

        // Build segments (words and citations)
        let segments = buildSegments(words: displayedWords, visibleCitations: visibleCitations)

        // Render using FlowLayout
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

    private func buildSegments(words: [String], visibleCitations: [CitationPosition]) -> [Segment] {
        var segments: [Segment] = []
        var lastWordIndex = 0

        for citationPos in visibleCitations {
            // Add words before citation
            if citationPos.wordIndex > lastWordIndex {
                for index in lastWordIndex..<citationPos.wordIndex {
                    let word = words[index]
                    if !word.isEmpty {
                        // Add space before word (except first word)
                        let wordWithSpace = index > 0 ? " \(word)" : word
                        segments.append(Segment(text: wordWithSpace, citation: nil))
                    } else {
                        // Empty string means there was a space, preserve it
                        segments.append(Segment(text: " ", citation: nil))
                    }
                }
            }

            // Add space before citation card
            segments.append(Segment(text: " ", citation: nil))

            // Add citation card
            segments.append(Segment(text: nil, citation: citationPos.citation))
            lastWordIndex = citationPos.wordIndex
        }

        // Add remaining words
        if lastWordIndex < words.count {
            for index in lastWordIndex..<words.count {
                let word = words[index]
                if !word.isEmpty {
                    let wordWithSpace = (index > 0 || lastWordIndex > 0) ? " \(word)" : word
                    segments.append(Segment(text: wordWithSpace, citation: nil))
                } else {
                    segments.append(Segment(text: " ", citation: nil))
                }
            }
        }

        return segments
    }

    private func startStreaming(words: [String]) {
        guard !words.isEmpty else { return }

        streamingTask?.cancel()

        // Get starting position from view model (resume where we left off)
        let startIndex = viewModel.getStreamingProgress(for: messageId)

        streamingTask = Task {
            // Initial delay (only on first start)
            if initialDelay > 0 && startIndex == 0 {
                try? await Task.sleep(nanoseconds: UInt64(initialDelay * 1_000_000_000))
            }

            for index in startIndex..<words.count {
                if Task.isCancelled { break }

                try? await Task.sleep(nanoseconds: UInt64(wordDelay * 1_000_000_000))

                await MainActor.run {
                    viewModel.updateStreamingProgress(for: messageId, wordCount: index + 1)
                    // Notify parent (optional, for scroll tracking)
                    onTextUpdate?("\(index + 1) words")
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
