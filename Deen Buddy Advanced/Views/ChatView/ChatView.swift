import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var vm = ChatViewModel()

    private let bubbleMaxWidth: CGFloat = 280
    @State private var scrollTrigger: Int = 0  // Trigger for scroll updates

    var body: some View {
        NavigationView {
            ZStack {
                // Background (adapts to light/dark mode)
                CreamyPapyrusBackground()

                VStack(spacing: 0) {

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 32) {
                            ForEach(vm.messages) { msg in
                                MessageRowView(
                                    message: msg,
                                    isStreaming: msg.id == vm.latestBotMessageId && msg.role == .bot,
                                    onStreamingUpdate: { _ in
                                        // Trigger scroll on each character update
                                        scrollTrigger += 1
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
                    .onChange(of: vm.messages.count) { newCount in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if let last = vm.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: vm.messages.last?.text) { newText in
                        print("📝 Last message text changed: \(newText?.prefix(50) ?? "nil")...")
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
                    TextField(AppStrings.chat.inputPlaceholder, text: $vm.input)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .foregroundColor(colorScheme == .dark ? .black : .primary)
                        .background(AppColors.Chat.inputBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

                    let canSend = !vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                    Button(action: vm.send) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.Chat.sendButtonIcon)
                            .padding(12)
                            .background(canSend ? AppColors.Chat.sendButtonActive(for: colorScheme) : AppColors.Chat.sendButtonInactive)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                    }
                    .disabled(!canSend)
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
