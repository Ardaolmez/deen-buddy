import SwiftUI

struct MessageRowView: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }

    // brand green (fallback)
    private let brand = Color(red: 0.29, green: 0.55, blue: 0.42) // #4A8B6A

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 24) }

            VStack(alignment: .leading, spacing: 6) {
                if !isUser {
                    Text("Deen Buddy:")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(brand)
                }

                Text(message.text)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(isUser ? .white : .primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isUser ? brand : Color(.systemGray6))
                    .shadow(color: .black.opacity(isUser ? 0.0 : 0.05), radius: 6, x: 0, y: 2)
            )

            if !isUser { Spacer(minLength: 24) }
        }
        .padding(.horizontal, 16)
        .transition(.move(edge: isUser ? .trailing : .leading).combined(with: .opacity))
    }
}
