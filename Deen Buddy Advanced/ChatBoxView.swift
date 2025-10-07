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
                    .foregroundColor(.secondary)

                Text("Ask me anything you're curious about Islam")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(.systemGray4), lineWidth: 1)
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
