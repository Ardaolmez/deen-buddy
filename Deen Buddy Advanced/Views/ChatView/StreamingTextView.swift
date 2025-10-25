//
//  StreamingTextView.swift
//  Deen Buddy Advanced
//
//  Character-by-character streaming text animation
//

import SwiftUI

struct StreamingTextView: View {
    let fullText: String
    let font: Font
    let color: Color
    let isStreaming: Bool
    var onTextUpdate: ((String) -> Void)? = nil  // Callback for scroll updates

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0

    // Animation speed (seconds per character)
    private let characterDelay: Double = 0.05

    var body: some View {
        Text(displayedText)
            .font(font)
            .foregroundStyle(color)
            .multilineTextAlignment(.leading)
            .onAppear {
                if isStreaming {
                    startStreaming()
                } else {
                    displayedText = fullText
                }
            }
            .onChange(of: fullText) { newValue in
                if isStreaming {
                    // Reset and restart streaming if text changes
                    displayedText = ""
                    currentIndex = 0
                    startStreaming()
                } else {
                    displayedText = newValue
                }
            }
    }

    private func startStreaming() {
        guard !fullText.isEmpty else { return }

        Task {
            for (index, character) in fullText.enumerated() {
                try? await Task.sleep(nanoseconds: UInt64(characterDelay * 1_000_000_000))

                await MainActor.run {
                    displayedText.append(character)
                    currentIndex = index + 1
                    onTextUpdate?(displayedText)  // Notify parent of text update
                }
            }
        }
    }
}

struct StreamingAttributedTextView: View {
    let segments: [MessageRowView.TextSegment]
    let isStreaming: Bool
    var onTextUpdate: ((String) -> Void)? = nil  // Callback for scroll updates

    @State private var displayedText: String = ""
    @State private var streamingComplete: Bool = false

    // Animation speed (seconds per character)
    private let characterDelay: Double = 0.03

    var body: some View {
        if streamingComplete || !isStreaming {
            // Show final attributed text with clickable citations
            renderAttributedText()
        } else {
            // Stream plain text first
            Text(displayedText)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .onAppear {
                    if isStreaming {
                        startStreaming()
                    } else {
                        streamingComplete = true
                    }
                }
        }
    }

    @ViewBuilder
    private func renderAttributedText() -> some View {
        Text(segments.map { segment -> AttributedString in
            switch segment {
            case .text(let string):
                var attributed = AttributedString(string)
                attributed.font = .system(size: 17, weight: .regular, design: .serif)
                attributed.foregroundColor = .primary
                return attributed
            case .citation(let number, let citation):
                let citationText = " (\(citation.surah) \(citation.ayah))"
                var attributed = AttributedString(citationText)
                attributed.font = .system(size: 14, weight: .medium)
                attributed.foregroundColor = AppColors.Chat.headerTitle
                attributed.link = URL(string: "citation://\(number)")
                return attributed
            }
        }.reduce(AttributedString(), +))
        .font(.system(size: 17, weight: .regular, design: .serif))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.leading)
    }

    private func startStreaming() {
        // Extract plain text from segments for streaming
        let plainText = segments.map { segment -> String in
            switch segment {
            case .text(let string):
                return string
            case .citation(_, let citation):
                return " (\(citation.surah) \(citation.ayah))"
            }
        }.joined()

        guard !plainText.isEmpty else {
            streamingComplete = true
            return
        }

        Task {
            for character in plainText {
                try? await Task.sleep(nanoseconds: UInt64(characterDelay * 1_000_000_000))

                await MainActor.run {
                    displayedText.append(character)
                    onTextUpdate?(displayedText)  // Notify parent of text update
                }
            }

            // Mark streaming as complete to show attributed text with citations
            await MainActor.run {
                streamingComplete = true
            }
        }
    }
}
