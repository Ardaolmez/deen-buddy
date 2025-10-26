import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var vm = ChatViewModel()

    private let bubbleMaxWidth: CGFloat = 280
    @State private var scrollTrigger: Int = 0  // Trigger for scroll updates
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                // Background (adapts to light/dark mode)
                CreamyPapyrusBackground()

                VStack(spacing: 0) {

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 36) {
                            ForEach(vm.messages) { msg in
                                MessageRowView(
                                    message: msg,
                                    isStreaming: msg.id == vm.latestBotMessageId && msg.role == .bot,
                                    onStreamingUpdate: { _ in
                                        // Trigger scroll on each character update
                                        scrollTrigger += 1
                                    },
                                    onStreamingComplete: {
                                        // Streaming finished, hide stop button
                                        vm.isStreaming = false
                                    }
                                )
                                    .id(msg.id)
                                    .padding(.horizontal, 16)
                            }
                            if vm.isSending {
                                MessageRowView(message: .init(role: .bot, text: AppStrings.chat.loadingIndicator))
                                    .redacted(reason: .placeholder)
                                    .padding(.horizontal, 16)
                            }
                            Spacer(minLength: 8)
                        }
                        .padding(.top, 12)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .onChange(of: vm.messages.count) { newCount in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if let last = vm.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: vm.messages.last?.text) { newText in
                        if let last = vm.messages.last {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: scrollTrigger) { _ in
                        // Scroll continuously as text streams in
                        if let last = vm.messages.last {
                            withAnimation(.easeOut(duration: 0.15)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input
                HStack(spacing: 12) {
                    TextField("", text: $vm.input, prompt: Text(AppStrings.chat.inputPlaceholder).foregroundColor(.black.opacity(0.5)))
                        .focused($isTextFieldFocused)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .foregroundColor(.black)
                        .tint(.black)
                        .background(AppColors.Chat.inputBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

                    let canSend = !vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                    // Show stop button when streaming, otherwise show send button
                    if vm.isStreaming {
                        Button(action: vm.stopStreaming) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.Chat.stopButtonIcon(for: colorScheme))
                                .padding(12)
                                .background(AppColors.Chat.stopButtonBackground(for: colorScheme))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        }
                    } else {
                        Button(action: vm.send) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.Chat.sendButtonIcon(for: colorScheme))
                                .padding(12)
                                .background(canSend ? AppColors.Chat.sendButtonActive(for: colorScheme) : AppColors.Chat.sendButtonInactive)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        }
                        .disabled(!canSend)
                    }
                }
                .padding()
                .background(Color.clear)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(AppStrings.chat.navigationTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.Chat.headerTitle(for: colorScheme))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.Chat.closeButton(for: colorScheme))
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatView()
}
