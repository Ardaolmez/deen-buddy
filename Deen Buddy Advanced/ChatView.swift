//
//  ChatView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Assalamu Alaikum! I'm here to help you learn about Islam. Feel free to ask me anything!", isUser: false)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                }

                                Text(message.text)
                                    .padding()
                                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .cornerRadius(16)
                                    .frame(maxWidth: .infinity * 0.7, alignment: message.isUser ? .trailing : .leading)

                                if !message.isUser {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }

                // Input
                HStack(spacing: 12) {
                    TextField("Type your question...", text: $messageText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(24)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .background(messageText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Islamic Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }

        messages.append(ChatMessage(text: messageText, isUser: true))

        // Simulate AI response
        let userMessage = messageText
        messageText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(ChatMessage(
                text: "Thank you for your question about \"\(userMessage)\". This is a placeholder response. In a full implementation, this would connect to an AI service to provide detailed Islamic knowledge.",
                isUser: false
            ))
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

#Preview {
    ChatView()
}
