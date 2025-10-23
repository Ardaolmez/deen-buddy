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

    private var bag = Set<AnyCancellable>()
    private let service: ChatService

    // ViewModels/ChatViewModel.swift (constructor)
    
    init(service: ChatService = GeminiChatService(
//        apiKey: Secrets.geminiAPIKey,
        apiKey: "arda",
                                                 modelName: "gemini-2.5-flash",
                                                 systemInstruction: "You are Deen Buddy, a kind Islamic guide. Keep answers concise, gentle, and grounded in mainstream scholarship.")) {
        self.service = service
        messages = [.init(role: .bot, text: AppStrings.chat.welcomeMessage)]
    }


    func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = ChatMessage(role: .user, text: trimmed)
        messages.append(userMsg)
        input = ""
        isSending = true

        service.reply(to: trimmed)
            .sink { [weak self] text in
                guard let self else { return }
                self.messages.append(.init(role: .bot, text: text))
                self.isSending = false
            }
            .store(in: &bag)
    }
}
