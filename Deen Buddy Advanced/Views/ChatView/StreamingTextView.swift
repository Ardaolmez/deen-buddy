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
