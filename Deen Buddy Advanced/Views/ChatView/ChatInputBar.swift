// Views/Chat/ChatInputBar.swift
import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            TextField(AppStrings.chat.inputPlaceholderShort, text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(AppColors.Chat.inputText(for: colorScheme))
                .tint(AppColors.Chat.inputText(for: colorScheme))
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppColors.Chat.inputBackground(for: colorScheme))
                        .shadow(color: AppColors.Chat.shadowMedium, radius: 10, x: 0, y: 4)
                )
                .lineLimit(1...5)

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.Chat.sendButtonIcon(for: colorScheme))
                    .padding(14)
                    .background(
                        Circle().fill(AppColors.Chat.sendButtonActive(for: colorScheme))
                    )
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
    }
}
