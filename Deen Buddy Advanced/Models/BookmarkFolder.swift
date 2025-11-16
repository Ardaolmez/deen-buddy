//
//  BookmarkFolder.swift
//  Deen Buddy Advanced
//
//  Model for bookmark folders containing Quran verses
//

import Foundation

struct BookmarkedVerse: Identifiable, Codable, Equatable {
    let id: UUID
    let surahId: Int
    let verseId: Int
    let addedAt: Date

    init(id: UUID = UUID(), surahId: Int, verseId: Int, addedAt: Date = Date()) {
        self.id = id
        self.surahId = surahId
        self.verseId = verseId
        self.addedAt = addedAt
    }

    var verseReference: String {
        return "\(surahId):\(verseId)"
    }
}

struct BookmarkFolder: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var verses: [BookmarkedVerse]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        verses: [BookmarkedVerse] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.verses = verses
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Helper computed properties
    var verseCount: Int {
        return verses.count
    }

    var isEmpty: Bool {
        return verses.isEmpty
    }

    // Mutating methods
    mutating func addVerse(surahId: Int, verseId: Int) {
        let verse = BookmarkedVerse(surahId: surahId, verseId: verseId)
        verses.append(verse)
        updatedAt = Date()
    }

    mutating func removeVerse(withId id: UUID) {
        verses.removeAll { $0.id == id }
        updatedAt = Date()
    }

    func containsVerse(surahId: Int, verseId: Int) -> Bool {
        return verses.contains { $0.surahId == surahId && $0.verseId == verseId }
    }
}
