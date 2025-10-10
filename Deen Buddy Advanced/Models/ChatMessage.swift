//
//  ChatMessage.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/6/25.
//

// Models/ChatMessage.swift
import Foundation

enum SenderRole: String, Codable {
    case user
    case bot
}

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id = UUID()
    let role: SenderRole
    var text: String
    var createdAt: Date = .init()
}
