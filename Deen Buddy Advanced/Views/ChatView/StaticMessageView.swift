//
//  StaticMessageView.swift
//  Deen Buddy Advanced
//
//  Displays bot messages instantly (no streaming animation)
//

import SwiftUI

struct StaticMessageView: View {
    let message: ChatMessage
    var onCitationTap: ((Citation) -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if !message.citations.isEmpty {
            // Message with citations - use flow layout with citation cards
            StaticTextWithCitationsView(
                message: message,
                onCitationTap: onCitationTap
            )
        } else {
            // Simple text message
            Text(message.text)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
    }
}

/// Displays text with inline citation cards (instant, no animation)
struct StaticTextWithCitationsView: View {
    let message: ChatMessage
    var onCitationTap: ((Citation) -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    private struct CitationPosition {
        let characterIndex: Int
        let citation: Citation
    }

    private var parsedData: (cleanText: String, citationPositions: [CitationPosition]) {
        var cleanText = ""
        var citationPositions: [CitationPosition] = []

        let pattern = #"\^\[([^\]]+)\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (message.text, [])
        }

        let nsString = message.text as NSString
        let matches = regex.matches(in: message.text, options: [], range: NSRange(location: 0, length: nsString.length))

        var citationMap: [String: Citation] = [:]
        for citation in message.citations {
            if citationMap[citation.ref] == nil {
                citationMap[citation.ref] = citation
            }
        }

        var lastEnd = 0
        var currentCleanPosition = 0

        for match in matches {
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let beforeText = nsString.substring(with: beforeRange)
                cleanText += beforeText
                currentCleanPosition += beforeText.count
            }

            if let refRange = Range(match.range(at: 1), in: message.text) {
                let ref = String(message.text[refRange])
                if let citation = citationMap[ref] {
                    citationPositions.append(CitationPosition(
                        characterIndex: currentCleanPosition,
                        citation: citation
                    ))
                }
            }

            lastEnd = match.range.location + match.range.length
        }

        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            cleanText += nsString.substring(with: remainingRange)
        }

        return (cleanText, citationPositions)
    }

    var body: some View {
        let parsed = parsedData
        let paragraphs = buildParagraphs(cleanText: parsed.cleanText, citationPositions: parsed.citationPositions)

        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { paragraphIndex, segments in
                FlowLayout(spacing: 0) {
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
                                    Image(systemName: AppStrings.chat.citationIconName)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(AppColors.Chat.citationCardIcon(for: colorScheme))

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
        }
    }

    private struct Segment {
        let text: String?
        let citation: Citation?
    }

    /// Builds paragraphs - each paragraph is an array of segments
    private func buildParagraphs(cleanText: String, citationPositions: [CitationPosition]) -> [[Segment]] {
        // Split text into paragraphs by newlines
        let paragraphTexts = cleanText.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        var paragraphs: [[Segment]] = []
        var currentCharIndex = 0

        for paragraphText in paragraphTexts {
            // Find where this paragraph starts in the original clean text
            if let range = cleanText.range(of: paragraphText, range: cleanText.index(cleanText.startIndex, offsetBy: currentCharIndex)..<cleanText.endIndex) {
                let paragraphStart = cleanText.distance(from: cleanText.startIndex, to: range.lowerBound)
                let paragraphEnd = paragraphStart + paragraphText.count

                // Get citations that fall within this paragraph
                let paragraphCitations = citationPositions.filter {
                    $0.characterIndex >= paragraphStart && $0.characterIndex <= paragraphEnd
                }

                // Build segments for this paragraph
                let segments = buildSegmentsForParagraph(
                    paragraphText: paragraphText,
                    paragraphStart: paragraphStart,
                    citations: paragraphCitations
                )

                if !segments.isEmpty {
                    paragraphs.append(segments)
                }

                currentCharIndex = paragraphEnd
            }
        }

        // If no paragraphs found (no newlines), treat entire text as one paragraph
        if paragraphs.isEmpty && !cleanText.isEmpty {
            let segments = buildSegmentsForParagraph(
                paragraphText: cleanText,
                paragraphStart: 0,
                citations: citationPositions
            )
            if !segments.isEmpty {
                paragraphs.append(segments)
            }
        }

        return paragraphs
    }

    private func buildSegmentsForParagraph(paragraphText: String, paragraphStart: Int, citations: [CitationPosition]) -> [Segment] {
        var segments: [Segment] = []
        var isFirstSegment = true
        var lastLocalIndex = 0

        // Sort citations by position
        let sortedCitations = citations.sorted { $0.characterIndex < $1.characterIndex }

        for citationPos in sortedCitations {
            // Convert global index to local paragraph index
            let localCitationIndex = citationPos.characterIndex - paragraphStart

            // Only process if citation is within this paragraph's bounds
            guard localCitationIndex >= 0 && localCitationIndex <= paragraphText.count else { continue }

            if localCitationIndex > lastLocalIndex {
                let startIdx = paragraphText.index(paragraphText.startIndex, offsetBy: lastLocalIndex)
                let endIdx = paragraphText.index(paragraphText.startIndex, offsetBy: min(localCitationIndex, paragraphText.count))
                let textSegment = String(paragraphText[startIdx..<endIdx])

                // Split by whitespace (space, tab, etc.) but not newlines since we already split by those
                let words = textSegment.components(separatedBy: .whitespaces)
                for word in words {
                    if !word.isEmpty {
                        if !isFirstSegment {
                            segments.append(Segment(text: " ", citation: nil))
                        }
                        segments.append(Segment(text: word, citation: nil))
                        isFirstSegment = false
                    }
                }
            }

            // Add citation
            if !isFirstSegment {
                segments.append(Segment(text: " ", citation: nil))
            }
            segments.append(Segment(text: nil, citation: citationPos.citation))
            isFirstSegment = false
            lastLocalIndex = localCitationIndex
        }

        // Add remaining text after last citation
        if lastLocalIndex < paragraphText.count {
            let startIdx = paragraphText.index(paragraphText.startIndex, offsetBy: lastLocalIndex)
            let remainingText = String(paragraphText[startIdx...])

            let words = remainingText.components(separatedBy: .whitespaces)
            for word in words {
                if !word.isEmpty {
                    if !isFirstSegment {
                        segments.append(Segment(text: " ", citation: nil))
                    }
                    segments.append(Segment(text: word, citation: nil))
                    isFirstSegment = false
                }
            }
        }

        return segments
    }
}
