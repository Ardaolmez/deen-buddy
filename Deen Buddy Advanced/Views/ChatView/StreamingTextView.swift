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
    var onStreamingComplete: (() -> Void)? = nil  // Callback when streaming finishes
    var initialDelay: Double = 0.5  // Optional delay before streaming starts

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var streamingTask: Task<Void, Never>? = nil

    // Animation speed (seconds per character)
    private let characterDelay: Double = 0.03

    var body: some View {
        Text(displayedText.isEmpty ? " " : displayedText)
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
            .onChange(of: isStreaming) { streaming in
                if !streaming {
                    // Stop streaming immediately - keep only what's been displayed
                    streamingTask?.cancel()
                    streamingTask = nil
                    // Don't show the rest of the text
                }
            }
            .onDisappear {
                streamingTask?.cancel()
            }
    }

    private func startStreaming() {
        guard !fullText.isEmpty else { return }

        streamingTask?.cancel()  // Cancel any existing task
        streamingTask = Task {
            // Optional initial delay before streaming
            if initialDelay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(initialDelay * 1_000_000_000))
            }

            for (index, character) in fullText.enumerated() {
                // Check if task was cancelled
                if Task.isCancelled {
                    break
                }

                try? await Task.sleep(nanoseconds: UInt64(characterDelay * 1_000_000_000))

                await MainActor.run {
                    displayedText.append(character)
                    currentIndex = index + 1
                    onTextUpdate?(displayedText)  // Notify parent of text update
                }
            }

            // Notify completion if we finished the full text
            if !Task.isCancelled {
                await MainActor.run {
                    onStreamingComplete?()
                }
            }
        }
    }
}

struct StreamingAttributedTextView: View {
    let segments: [MessageRowView.TextSegment]
    let isStreaming: Bool
    var onTextUpdate: ((String) -> Void)? = nil  // Callback for scroll updates

    @Environment(\.colorScheme) var colorScheme
    @State private var displayedText: String = ""
    @State private var streamingComplete: Bool = false

    // Animation speed (seconds per character)
    private let characterDelay: Double = 0.04

    var body: some View {
        if streamingComplete || !isStreaming {
            // Show final attributed text with clickable citations
            renderAttributedText()
        } else {
            // Stream plain text first
            Text(displayedText)
                .font(.system(size: 18, weight: .regular, design: .serif))
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
                attributed.font = .system(size: 18, weight: .regular, design: .serif)
                attributed.foregroundColor = .primary
                return attributed
            case .citation(let number, let citation):
                let citationText = " (\(citation.surah) \(citation.ayah))"
                var attributed = AttributedString(citationText)
                attributed.font = .system(size: 14, weight: .medium)
                attributed.foregroundColor = AppColors.Chat.headerTitle(for: colorScheme)
                attributed.link = URL(string: "citation://\(number)")
                return attributed
            }
        }.reduce(AttributedString(), +))
        .font(.system(size: 18, weight: .regular, design: .serif))
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
