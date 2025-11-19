//
//  StreamingTextView.swift
//  Deen Buddy Advanced
//
//  Word-by-word streaming text animation
//

import SwiftUI

struct StreamingTextView: View {
    let messageId: UUID?
    let fullText: String
    let font: Font
    let color: Color
    let isStreaming: Bool
    var viewModel: ChatViewModel? = nil
    var onTextUpdate: ((String) -> Void)? = nil  // Callback for scroll updates
    var onStreamingComplete: (() -> Void)? = nil  // Callback when streaming finishes
    var initialDelay: Double = 0.5  // Optional delay before streaming starts

    @State private var displayedText: String = ""
    @State private var currentWordIndex: Int = 0  // Fallback when no viewModel
    @State private var streamingTask: Task<Void, Never>? = nil

    // Animation speed (seconds per word)
    private let wordDelay: Double = 0.08

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
                    currentWordIndex = 0
                    if let viewModel = viewModel, let messageId = messageId {
                        viewModel.updateStreamingProgress(for: messageId, wordCount: 0)
                    }
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

        // Split text into words (preserving spaces and punctuation)
        let words = fullText.split(separator: " ", omittingEmptySubsequences: false).map(String.init)

        // Get starting position from view model (resume where we left off) or use local state
        let startIndex: Int
        if let viewModel = viewModel, let messageId = messageId {
            startIndex = viewModel.getStreamingProgress(for: messageId)
        } else {
            startIndex = currentWordIndex
        }

        // Rebuild displayedText from stored progress
        if startIndex > 0 {
            var rebuilt = ""
            for i in 0..<min(startIndex, words.count) {
                if i > 0 {
                    rebuilt += " " + words[i]
                } else {
                    rebuilt = words[i]
                }
            }
            displayedText = rebuilt
        }

        streamingTask = Task {
            // Optional initial delay before streaming (only on first start)
            if initialDelay > 0 && startIndex == 0 {
                try? await Task.sleep(nanoseconds: UInt64(initialDelay * 1_000_000_000))
            }

            for index in startIndex..<words.count {
                // Check if task was cancelled
                if Task.isCancelled {
                    break
                }

                try? await Task.sleep(nanoseconds: UInt64(wordDelay * 1_000_000_000))

                await MainActor.run {
                    let word = words[index]
                    // Add word with space (except for first word)
                    if index > 0 {
                        displayedText += " " + word
                    } else {
                        displayedText = word
                    }

                    // Update progress in view model if available, otherwise use local state
                    if let viewModel = viewModel, let messageId = messageId {
                        viewModel.updateStreamingProgress(for: messageId, wordCount: index + 1)
                    } else {
                        currentWordIndex = index + 1
                    }

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
