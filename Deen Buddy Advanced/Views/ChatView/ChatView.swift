import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = ChatViewModel()

    private let bubbleMaxWidth: CGFloat = 280
    @State private var scrollTrigger: Int = 0  // Trigger for scroll updates

    var body: some View {
        NavigationView {
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
                                    .onAppear {
                                        print("✅ MessageRowView appeared - ID: \(msg.id), Role: \(msg.role.rawValue), Text: \(msg.text.prefix(50))...")
                                    }
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
                        print("📊 Message count changed to: \(newCount)")
                        if let last = vm.messages.last {
                            print("📍 Last message ID: \(last.id)")
                            print("📝 Last message text: \(last.text.prefix(50))...")
                            print("🎯 Scrolling to message ID: \(last.id)")
                        }
                        withAnimation(.easeOut(duration: 0.2)) {
                            if let last = vm.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: vm.messages.last?.text) { newText in
                        print("📝 Last message text changed: \(newText?.prefix(50) ?? "nil")...")
                        if let last = vm.messages.last {
                            print("🔄 Streaming update - scrolling to ID: \(last.id)")
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: vm.latestBotMessageId) { newID in
                        print("🤖 Latest bot message ID changed: \(newID?.uuidString ?? "nil")")
                    }
                    .onChange(of: scrollTrigger) { _ in
                        // Scroll continuously as text streams in
                        if let last = vm.messages.last {
                            print("🔄 Streaming scroll trigger - count: \(scrollTrigger)")
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
                        .background(AppColors.Chat.inputBackground)
                        .cornerRadius(24)

                    let canSend = !vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                    Button(action: vm.send) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.Chat.sendButtonIcon)
                            .padding(12)
                            .background(canSend ? AppColors.Chat.sendButtonActive : AppColors.Chat.sendButtonInactive)
                            .clipShape(Circle())
                    }
                    .disabled(!canSend)
                }
                .padding()
                .background(AppColors.Chat.containerBackground)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(AppStrings.chat.navigationTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.Chat.headerTitle)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.Chat.closeButton)
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
