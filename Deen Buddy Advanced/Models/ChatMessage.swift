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

/// Represents a Quran citation with surah and verse reference
struct Citation: Codable, Equatable, Hashable, Identifiable {
    let id = UUID()
    let ref: String          // e.g., "Quran 2:45"
    let surah: String        // Surah name (e.g., "Al-Baqarah")
    let ayah: Int            // Verse/ayah number
    let text: String         // Verse text in English

    enum CodingKeys: String, CodingKey {
        case ref, surah, ayah, text
    }
}

struct ChatMessage: Identifiable, Equatable, Hashable {
    let id = UUID()
    let role: SenderRole
    var text: String
    var citations: [Citation] = []  // Quran citations for this message
    var createdAt: Date = .init()
}
