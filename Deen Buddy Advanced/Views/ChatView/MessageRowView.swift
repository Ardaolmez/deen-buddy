import SwiftUI

struct MessageRowView: View {
    let message: ChatMessage
    var shouldAnimateWelcome: Bool = true  // Whether welcome message should animate
    var onWelcomeAnimationComplete: (() -> Void)? = nil  // Callback when welcome animation finishes

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

                // Render message content
                if isUser {
                    // User messages - simple text
                    Text(message.text)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.Chat.userText(for: colorScheme))
                        .multilineTextAlignment(.leading)
                } else if message.isWelcomeMessage && shouldAnimateWelcome {
                    // Welcome message - use streaming animation (only first time)
                    if !message.citations.isEmpty {
                        StreamingTextWithCitationsView(
                            fullText: message.text,
                            citations: message.citations,
                            isStreaming: true,
                            onStreamingComplete: onWelcomeAnimationComplete,
                            onCitationTap: { citation in
                                selectedCitation = citation
                            },
                            initialDelay: 0.5
                        )
                    } else {
                        StreamingTextView(
                            fullText: message.text,
                            font: .system(size: 18, weight: .regular, design: .serif),
                            color: .primary,
                            isStreaming: true,
                            onStreamingComplete: onWelcomeAnimationComplete,
                            initialDelay: 0.5
                        )
                    }
                } else {
                    // Regular bot messages or welcome message after animation - appear instantly
                    StaticMessageView(
                        message: message,
                        onCitationTap: { citation in
                            selectedCitation = citation
                        }
                    )
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
}
