import SwiftUI

struct MessageRowView: View {
    let message: ChatMessage
    var isStreaming: Bool = false  // Enable streaming animation for new bot messages
    var onStreamingUpdate: ((String) -> Void)? = nil  // Callback for streaming text updates

    private var isUser: Bool { message.role == .user }

    @Environment(\.colorScheme) var colorScheme
    @State private var selectedCitation: Citation?

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 24) }

            VStack(alignment: .leading, spacing: isUser ? 6 : 8) {
                if !isUser {
                    Text(AppStrings.chat.botName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.Chat.headerTitle(for: colorScheme))
                        .padding(.bottom, 2)
                }

                // Parse and render message with clickable citations
                if !isUser && !message.citations.isEmpty {
                    renderMessageWithCitations()
                } else if !isUser && isStreaming {
                    // Stream bot messages character by character
                    StreamingTextView(
                        fullText: message.text,
                        font: .system(size: 18, weight: .regular, design: .serif),
                        color: .primary,
                        isStreaming: true,
                        onTextUpdate: onStreamingUpdate,
                        initialDelay: message.isWelcomeMessage ? 0.5 : 0.0
                    )
                } else {
                    Text(message.text)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(isUser ? AppColors.Chat.userText(for: colorScheme) : .primary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, isUser ? 10 : 0)
            .padding(.horizontal, isUser ? 14 : 0)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isUser ? AppColors.Chat.sendButtonActive(for: colorScheme) : Color.clear)
                    .shadow(color: isUser ? Color.black.opacity(0.12) : Color.clear, radius: 8, x: 0, y: 3)
                    .shadow(color: isUser ? Color.black.opacity(0.06) : Color.clear, radius: 2, x: 0, y: 1)
            )

            if !isUser { Spacer(minLength: 24) }
        }
        .padding(.horizontal, isUser ? 16 : 0)
        .transition(.move(edge: isUser ? .trailing : .leading).combined(with: .opacity))
        .sheet(item: $selectedCitation) { citation in
            VersePopupView(surahName: citation.surah, verseNumber: citation.ayah)
        }
    }

    @ViewBuilder
    private func renderMessageWithCitations() -> some View {
        let textSegments = parseText()

        if isStreaming {
            // Stream text with citations
            StreamingAttributedTextView(segments: textSegments, isStreaming: true, onTextUpdate: onStreamingUpdate)
                .environment(\.openURL, OpenURLAction { url in
                    // Handle citation taps
                    if url.scheme == "citation",
                       let numberString = url.host,
                       let number = Int(numberString),
                       number > 0 && number <= message.citations.count {
                        selectedCitation = message.citations[number - 1]
                    }
                    return .handled
                })
        } else {
            // Show full text immediately
            Text(textSegments.map { segment -> AttributedString in
                switch segment {
                case .text(let string):
                    var attributed = AttributedString(string)
                    attributed.font = .system(size: 18, weight: .regular, design: .serif)
                    attributed.foregroundColor = .primary
                    return attributed
                case .citation(let number, let citation):
                    // Extract surah name and ayah from citation
                    // Format: (Surah ayah) e.g., (Al-Baqarah 2:45)
                    let citationText = " (\(citation.surah) \(citation.ayah))"
                    var attributed = AttributedString(citationText)
                    attributed.font = .system(size: 14, weight: .medium)
                    attributed.foregroundColor = AppColors.Chat.headerTitle(for: colorScheme)
                    // Store citation index in link attribute
                    attributed.link = URL(string: "citation://\(number)")
                    return attributed
                }
            }.reduce(AttributedString(), +))
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .environment(\.openURL, OpenURLAction { url in
                // Handle citation taps
                if url.scheme == "citation",
                   let numberString = url.host,
                   let number = Int(numberString),
                   number > 0 && number <= message.citations.count {
                    selectedCitation = message.citations[number - 1]
                }
                return .handled
            })
        }
    }

    enum TextSegment {
        case text(String)
        case citation(Int, Citation)
    }

    /// Helper function to parse text
    private func parseText() -> [TextSegment] {
        return parseTextWithCitations(message.text, citations: message.citations)
    }

    /// Parse message text and replace citation markers with numbered citations
    /// Example: "Hello^[Quran 2:45] world" -> ["Hello", citation(1), " world"]
    private func parseTextWithCitations(_ text: String, citations: [Citation]) -> [TextSegment] {
        var segments: [TextSegment] = []

        // Build a map of citation ref -> citation for quick lookup
        let citationMap = Dictionary(uniqueKeysWithValues: citations.enumerated().map { (index, citation) in
            (citation.ref, (index + 1, citation))
        })

        // Pattern to match citation markers: ^[Quran 2:45]
        let pattern = #"\^\[([^\]]+)\]"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [.text(text)]
        }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastEnd = 0

        for match in matches {
            // Add text before the citation marker
            if match.range.location > lastEnd {
                let beforeRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let beforeText = nsString.substring(with: beforeRange)
                if !beforeText.isEmpty {
                    segments.append(.text(beforeText))
                }
            }

            // Extract citation ref (e.g., "Quran 2:45")
            if let refRange = Range(match.range(at: 1), in: text) {
                let ref = String(text[refRange])

                // Look up the citation
                if let (number, citation) = citationMap[ref] {
                    segments.append(.citation(number, citation))
                }
            }

            lastEnd = match.range.location + match.range.length
        }

        // Add remaining text after last citation
        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            let remainingText = nsString.substring(with: remainingRange)
            if !remainingText.isEmpty {
                segments.append(.text(remainingText))
            }
        }

        return segments.isEmpty ? [.text(text)] : segments
    }
}
