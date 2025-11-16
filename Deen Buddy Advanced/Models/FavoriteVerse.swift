//
//  FavoriteVerse.swift
//  Deen Buddy Advanced
//
//  Model for a favorited Quran verse
//

import Foundation

struct FavoriteVerse: Identifiable, Codable, Equatable {
    let id: UUID
    let surahId: Int
    let verseId: Int
    let timestamp: Date

    init(id: UUID = UUID(), surahId: Int, verseId: Int, timestamp: Date = Date()) {
        self.id = id
        self.surahId = surahId
        self.verseId = verseId
        self.timestamp = timestamp
    }

    // Helper computed properties
    var verseReference: String {
        return "\(surahId):\(verseId)"
    }
}
