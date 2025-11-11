//
//  WordOfWisdom.swift
//  Deen Buddy Advanced
//
//  Model for Word of Wisdom quotes
//

import Foundation

struct WordOfWisdom: Codable, Identifiable {
    var id: UUID = UUID()
    let quote: String
    let author: String
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case quote, author, explanation
    }
}
