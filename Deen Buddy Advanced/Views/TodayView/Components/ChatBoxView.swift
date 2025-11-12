//
//  TodayChatBoxView.swift
//  Deen Buddy Advanced
//
//  Chat box for Today view with custom prompt text
//

import SwiftUI

struct ChatBoxView: View {
    @State private var showChat = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            showChat = true
        }) {
            // Text input field styling matching ChatView
            HStack {
                Text(AppStrings.chat.todayChatBoxPrompt)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Chat.inputPlaceholder(for: colorScheme))
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(AppColors.Chat.inputBackground(for: colorScheme))
            .cornerRadius(24)
            // Enhanced 3D shadow effect with multiple layers
            .shadow(color: AppColors.Chat.headerTitle(for: colorScheme).opacity(0.4), radius: 12, x: 0, y: 4)
            .shadow(color: AppColors.Chat.headerTitle(for: colorScheme).opacity(0.2), radius: 8, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 0.5)
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView()
        }
    }
}

// MARK: - Sticky Chat Box with Gradient Fade

struct StickyChatBox: View {
    var body: some View {
        VStack(spacing: 0) {
            // Gradient fade from transparent to background color
            LinearGradient(
                colors: [
                    AppColors.Today.papyrusBackground.opacity(0),
                    AppColors.Today.papyrusBackground.opacity(0),
                    AppColors.Today.papyrusBackground.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 10)

            ChatBoxView()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    ChatBoxView()
        .padding()
}
