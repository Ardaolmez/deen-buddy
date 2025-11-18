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
        let segments = buildSegments(cleanText: parsed.cleanText, citationPositions: parsed.citationPositions)

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

    private struct Segment {
        let text: String?
        let citation: Citation?
    }

    private func buildSegments(cleanText: String, citationPositions: [CitationPosition]) -> [Segment] {
        var segments: [Segment] = []
        var lastIndex = 0

        for citationPos in citationPositions {
            if citationPos.characterIndex > lastIndex {
                let startIdx = cleanText.index(cleanText.startIndex, offsetBy: lastIndex)
                let endIdx = cleanText.index(cleanText.startIndex, offsetBy: citationPos.characterIndex)
                let textSegment = String(cleanText[startIdx..<endIdx])

                let words = textSegment.components(separatedBy: " ")
                for (index, word) in words.enumerated() {
                    if !word.isEmpty {
                        let wordWithSpace = index > 0 ? " \(word)" : word
                        segments.append(Segment(text: wordWithSpace, citation: nil))
                    } else if index < words.count - 1 {
                        segments.append(Segment(text: " ", citation: nil))
                    }
                }
            }

            segments.append(Segment(text: " ", citation: nil))
            segments.append(Segment(text: nil, citation: citationPos.citation))
            lastIndex = citationPos.characterIndex
        }

        if lastIndex < cleanText.count {
            let startIdx = cleanText.index(cleanText.startIndex, offsetBy: lastIndex)
            let remainingText = String(cleanText[startIdx...])

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
}
