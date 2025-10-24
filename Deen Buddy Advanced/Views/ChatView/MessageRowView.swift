import SwiftUI

// Helper to make fullScreenCover background transparent
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct MessageRowView: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }

    // brand green (fallback)
    private let brand = Color(red: 0.29, green: 0.55, blue: 0.42) // #4A8B6A

    @State private var selectedCitation: Citation?
    @State private var showCitationPopup = false

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 24) }

            VStack(alignment: .leading, spacing: 6) {
                if !isUser {
                    Text(AppStrings.chat.botName)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(brand)
                }

                // Parse and render message with clickable citations
                if !isUser && !message.citations.isEmpty {
                    renderMessageWithCitations()
                } else {
                    Text(message.text)
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .foregroundStyle(isUser ? .white : .primary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isUser ? brand : Color(.systemGray6))
                    .shadow(color: .black.opacity(isUser ? 0.0 : 0.05), radius: 6, x: 0, y: 2)
            )

            if !isUser { Spacer(minLength: 24) }
        }
        .padding(.horizontal, 16)
        .transition(.move(edge: isUser ? .trailing : .leading).combined(with: .opacity))
        .fullScreenCover(isPresented: $showCitationPopup) {
            if let citation = selectedCitation {
                CitationPopupView(citation: citation)
                    .background(BackgroundClearView())
            }
        }
    }

    @ViewBuilder
    private func renderMessageWithCitations() -> some View {
        let textSegments = parseTextWithCitations(message.text, citations: message.citations)

        // Use HStack with wrapping to display text segments with clickable citations
        Text(textSegments.map { segment -> AttributedString in
            switch segment {
            case .text(let string):
                var attributed = AttributedString(string)
                attributed.font = .system(size: 17, weight: .regular, design: .serif)
                attributed.foregroundColor = .primary
                return attributed
            case .citation(let number, let citation):
                // Extract surah name and ayah from citation
                // Format: (Surah ayah) e.g., (Al-Baqarah 2:45)
                let citationText = " (\(citation.surah) \(citation.ayah))"
                var attributed = AttributedString(citationText)
                attributed.font = .system(size: 14, weight: .medium)
                attributed.foregroundColor = Color(red: 0.29, green: 0.55, blue: 0.42)
                // Store citation index in link attribute
                attributed.link = URL(string: "citation://\(number)")
                return attributed
            }
        }.reduce(AttributedString(), +))
        .font(.system(size: 17, weight: .regular, design: .serif))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
        .environment(\.openURL, OpenURLAction { url in
            // Handle citation taps
            if url.scheme == "citation",
               let numberString = url.host,
               let number = Int(numberString),
               number > 0 && number <= message.citations.count {
                selectedCitation = message.citations[number - 1]
                showCitationPopup = true
            }
            return .handled
        })
    }

    private enum TextSegment {
        case text(String)
        case citation(Int, Citation)
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
