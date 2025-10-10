//
//  ChatService.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/6/25.
//

// Services/ChatService.swift
import Foundation
import Combine

protocol ChatService {
    func reply(to userText: String) -> AnyPublisher<String, Never>
}
