//
//  ChatService.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/6/25.
//

// Services/ChatService.swift
import Foundation
import Combine

/// Response from a chat service
struct ChatServiceResponse {
    let answer: String
    let citations: [Citation]
}

protocol ChatService {
    func reply(to userText: String) -> AnyPublisher<ChatServiceResponse, Never>
}
