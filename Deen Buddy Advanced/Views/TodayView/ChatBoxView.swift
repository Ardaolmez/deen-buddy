//
//  ChatBoxView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ChatBoxView: View {
    @State private var showChat = false

    var body: some View {
        Button(action: {
            showChat = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.Chat.boxIcon)

                Text(AppStrings.chat.chatBoxPrompt)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.Chat.boxText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(AppColors.Chat.boxBackground)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(AppColors.Chat.boxBorder, lineWidth: 1)
            )
        }
        .fullScreenCover(isPresented: $showChat) {
            ChatView()
        }
    }
}

#Preview {
    ChatBoxView()
        .padding()
}
