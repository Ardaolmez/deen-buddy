import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = ChatViewModel()

    private let bubbleMaxWidth: CGFloat = 280

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(vm.messages) { msg in
                                MessageRowView(message: msg)
                                    .id(msg.id)
                                    .padding(.horizontal, 16)
                            }
                            if vm.isSending {
                                MessageRowView(message: .init(role: .bot, text: "…"))
                                    .redacted(reason: .placeholder)
                                    .padding(.horizontal, 16)
                            }
                            Spacer(minLength: 8)
                        }
                        .padding(.top, 12)
                    }
                    .onChange(of: vm.messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if let last = vm.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                // Input
                HStack(spacing: 12) {
                    TextField(AppStrings.chat.inputPlaceholder, text: $vm.input)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(24)

                    let canSend = !vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                    Button(action: vm.send) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(canSend ? Color.blue : Color.gray)
                            .clipShape(Circle())
                    }
                    .disabled(!canSend)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationBarTitle(AppStrings.chat.navigationTitle, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.chat.close) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
