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
    @Published var latestBotMessageId: UUID? = nil  // Track latest bot message for streaming
    @Published var isStreaming = false  // Track if bot is currently typing

    private var bag = Set<AnyCancellable>()
    private let service: ChatService

    // ViewModels/ChatViewModel.swift (constructor)

    init(service: ChatService = CloudflareChatService()) {
        self.service = service
        let welcomeMessage = ChatMessage(role: .bot, text: AppStrings.chat.welcomeMessage, isWelcomeMessage: true)
        messages = [welcomeMessage]
        latestBotMessageId = welcomeMessage.id  // Mark welcome message for streaming
        // Don't show stop button for welcome message
    }


    func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = ChatMessage(role: .user, text: trimmed)
        messages.append(userMsg)
        input = ""
        isSending = true

        service.reply(to: trimmed)
            .sink { [weak self] response in
                guard let self else { return }
                let botMessage = ChatMessage(
                    role: .bot,
                    text: response.answer,
                    citations: response.citations
                )
                self.messages.append(botMessage)
                self.latestBotMessageId = botMessage.id  // Mark for streaming animation
                self.isStreaming = true  // Start streaming
                self.isSending = false
            }
            .store(in: &bag)
    }

    func stopStreaming() {
        isStreaming = false
        latestBotMessageId = nil  // Clear streaming marker to stop animation
    }
}
