//
//  ChatViewModel.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/6/25.
//

// ViewModels/ChatViewModel.swift
import Foundation
import Combine
import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isSending = false
    @Published var welcomeMessageHasAnimated = false  // Track if welcome message animation completed

    private var bag = Set<AnyCancellable>()
    private let service: ChatService

    // ViewModels/ChatViewModel.swift (constructor)

    init(service: ChatService = CloudflareChatService(), initialMessage: String? = nil) {
        self.service = service
        var welcomeMessage = ChatMessage(role: .bot, text: AppStrings.chat.welcomeMessage, isWelcomeMessage: true)
        // Only welcome message gets streaming animation
        welcomeMessage.shouldUseStreamingView = true

        // If there's an initial message, hide the welcome message
        if initialMessage != nil {
            welcomeMessage.isHidden = true
        }

        messages = [welcomeMessage]

        // If there's an initial message, send it automatically and hide it
        if let initialMessage = initialMessage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.input = initialMessage
                self.sendHidden()  // Send but hide the user message
            }
        }
    }


    func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = ChatMessage(role: .user, text: trimmed)
        messages.append(userMsg)
        input = ""
        isSending = true

        // Get conversation history (exclude welcome message)
        let conversationHistory = messages.filter { !$0.isWelcomeMessage && $0.id != userMsg.id }

        service.reply(to: trimmed, history: conversationHistory)
            .sink { [weak self] response in
                guard let self else { return }
                // Regular bot messages appear instantly (no streaming)
                let botMessage = ChatMessage(
                    role: .bot,
                    text: response.answer,
                    citations: response.citations
                )
                self.messages.append(botMessage)
                self.isSending = false
            }
            .store(in: &bag)
    }

    // Send a message but mark it as hidden (for auto-sent context messages)
    private func sendHidden() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var userMsg = ChatMessage(role: .user, text: trimmed)
        userMsg.isHidden = true  // Hide this message from UI
        messages.append(userMsg)
        input = ""
        isSending = true

        // Get conversation history (exclude welcome message)
        let conversationHistory = messages.filter { !$0.isWelcomeMessage && $0.id != userMsg.id }

        service.reply(to: trimmed, history: conversationHistory)
            .sink { [weak self] response in
                guard let self else { return }
                // Regular bot messages appear instantly (no streaming)
                let botMessage = ChatMessage(
                    role: .bot,
                    text: response.answer,
                    citations: response.citations
                )
                self.messages.append(botMessage)
                self.isSending = false
            }
            .store(in: &bag)
    }
}
