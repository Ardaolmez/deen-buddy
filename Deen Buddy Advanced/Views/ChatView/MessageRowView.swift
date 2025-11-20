import SwiftUI

struct MessageRowView: View {
    let message: ChatMessage
    @ObservedObject var viewModel: ChatViewModel
    var shouldAnimateWelcome: Bool = true  // Whether welcome message should animate
    var onWelcomeAnimationComplete: (() -> Void)? = nil  // Callback when welcome animation finishes
    var isKeyboardOpen: Bool = false  // Track if keyboard is open
    var dismissKeyboard: (() -> Void)? = nil  // Closure to dismiss keyboard
    @Binding var selectedCitation: Citation?  // Binding to parent's citation state

    private var isUser: Bool { message.role == .user }

    @Environment(\.colorScheme) var colorScheme

    // Check if animation has completed using global tracking
    private var hasCompletedAnimation: Bool {
        viewModel.hasCompletedAnimation(for: message.id)
    }

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
                } else if message.shouldUseStreamingView && !hasCompletedAnimation {
                    // Bot messages with streaming animation (only once per message)
                    if !message.citations.isEmpty {
                        StreamingTextWithCitationsView(
                            messageId: message.id,
                            fullText: message.text,
                            citations: message.citations,
                            isStreaming: true,
                            viewModel: viewModel,
                            onStreamingComplete: {
                                viewModel.markAnimationComplete(for: message.id)
                                if message.isWelcomeMessage {
                                    onWelcomeAnimationComplete?()
                                }
                            },
                            onCitationTap: { citation in
                                if isKeyboardOpen {
                                    dismissKeyboard?()
                                    return
                                }
                                selectedCitation = citation
                            },
                            initialDelay: message.isWelcomeMessage ? 0.5 : 0.0
                        )
                    } else {
                        StreamingTextView(
                            messageId: message.id,
                            fullText: message.text,
                            font: .system(size: 18, weight: .regular, design: .serif),
                            color: .primary,
                            isStreaming: true,
                            viewModel: viewModel,
                            onStreamingComplete: {
                                viewModel.markAnimationComplete(for: message.id)
                                if message.isWelcomeMessage {
                                    onWelcomeAnimationComplete?()
                                }
                            },
                            initialDelay: message.isWelcomeMessage ? 0.5 : 0.0
                        )
                    }
                } else {
                    // Bot messages after streaming completes or on scroll/re-render - appear instantly
                    StaticMessageView(
                        message: message,
                        onCitationTap: { citation in
                            if isKeyboardOpen {
                                dismissKeyboard?()
                                return
                            }
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
    }
}
