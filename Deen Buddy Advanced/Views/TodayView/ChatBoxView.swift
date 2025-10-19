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
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.Chat.boxIcon)

                Text(AppStrings.chat.chatBoxPrompt)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Chat.boxText)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .background(AppColors.Chat.boxBackground)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(AppColors.Chat.boxBorder, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showChat) {
            ChatView()
        }
    }
}

#Preview {
    ChatBoxView()
}
