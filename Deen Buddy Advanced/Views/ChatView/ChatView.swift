import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    let initialMessage: String?
    @StateObject private var vm: ChatViewModel

    @FocusState private var isTextFieldFocused: Bool
    @State private var isUserAtBottom: Bool = true  // Track if user scrolled away from bottom

    init(initialMessage: String? = nil) {
        self.initialMessage = initialMessage
        _vm = StateObject(wrappedValue: ChatViewModel(initialMessage: initialMessage))
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background (adapts to light/dark mode)
                CreamyPapyrusBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 36) {
                                ForEach(vm.messages.filter { !$0.isHidden }) { msg in
                                    MessageRowView(
                                        message: msg,
                                        viewModel: vm,
                                        shouldAnimateWelcome: !vm.welcomeMessageHasAnimated,
                                        onWelcomeAnimationComplete: {
                                            vm.welcomeMessageHasAnimated = true
                                        },
                                        isKeyboardOpen: isTextFieldFocused,
                                        dismissKeyboard: {
                                            isTextFieldFocused = false
                                        }
                                    )
                                        .id(msg.id)
                                        .padding(.horizontal, 16)
                                }
                                if vm.isSending {
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(AppStrings.chat.botName)
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(AppColors.Chat.headerTitle(for: colorScheme))
                                                .padding(.bottom, 2)

                                            VStack(alignment: .leading, spacing: 8) {
                                                ForEach(0..<3, id: \.self) { index in
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: index == 2 ? 180 : 280, height: 18)
                                                }
                                            }
                                        }

                                        Spacer(minLength: 24)
                                    }
                                    .padding(.horizontal, 16)
                                    .id("loading")
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                        .simultaneousGesture(
                            DragGesture().onChanged { _ in
                                isUserAtBottom = false  // User is manually scrolling
                            }
                        )
                        .onAppear {
                            // Open keyboard on first load
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                        }
                        .onChange(of: vm.messages.count) { _ in
                            // New message arrived - scroll to show user's last question at top
                            isUserAtBottom = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                // Find the last user message
                                if let lastUserMessage = vm.messages.filter({ $0.role == .user && !$0.isHidden }).last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastUserMessage.id, anchor: .top)
                                    }
                                }
                            }
                        }
                        .onChange(of: vm.isSending) { isSending in
                            // Scroll to loading animation when it appears
                            if isSending {
                                isUserAtBottom = true  // New activity, reset to bottom
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo("loading", anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isTextFieldFocused) { focused in
                            if focused {
                                // Keyboard opening - scroll to bottom with matching spring animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let lastMessage = vm.messages.filter({ !$0.isHidden }).last {
                                        withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0)) {
                                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                        }
                                    } else if vm.isSending {
                                        withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0)) {
                                            proxy.scrollTo("loading", anchor: .bottom)
                                        }
                                    }
                                }
                            } else {
                                // Keyboard closing - scroll immediately with matching spring animation
                                if let lastUserMessage = vm.messages.filter({ $0.role == .user && !$0.isHidden }).last {
                                    withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0)) {
                                        proxy.scrollTo(lastUserMessage.id, anchor: .top)
                                    }
                                }
                            }
                        }
                    }

                    // Input
                    HStack(spacing: 12) {
                        TextField("", text: $vm.input, prompt: Text(AppStrings.chat.inputPlaceholder).foregroundColor(AppColors.Chat.inputPlaceholder(for: colorScheme)))
                            .focused($isTextFieldFocused)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .foregroundColor(AppColors.Chat.inputText(for: colorScheme))
                            .tint(AppColors.Chat.inputText(for: colorScheme))
                            .background(AppColors.Chat.inputBackground(for: colorScheme))
                            .cornerRadius(24)
                            .shadow(color: AppColors.Chat.shadowMedium, radius: 8, x: 0, y: 2)
                            .shadow(color: AppColors.Chat.shadowLight, radius: 2, x: 0, y: 1)

                        let canSend = !vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                        // Send button
                        Button(action: vm.send) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.Chat.sendButtonIcon(for: colorScheme))
                                .padding(12)
                                .background(canSend ? AppColors.Chat.sendButtonActive(for: colorScheme) : AppColors.Chat.sendButtonInactive)
                                .clipShape(Circle())
                                .shadow(color: AppColors.Chat.shadowStrong, radius: 8, x: 0, y: 3)
                                .shadow(color: AppColors.Chat.shadowLight, radius: 2, x: 0, y: 1)
                        }
                        .disabled(!canSend)
                    }
                    .padding()
                    .background(Color.clear)
                }
                .keyboardAdaptive()
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
