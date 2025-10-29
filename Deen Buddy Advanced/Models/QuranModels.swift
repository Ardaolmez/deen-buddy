//
//  QuranModels.swift
//  Deen Buddy Advanced
//
//  Data models for Quran content
//

import Foundation

// Represents a single verse (Ayah) in the Quran
struct Verse: Codable, Identifiable, Equatable {
    let id: Int
    let text: String              // Arabic text
    let translation: String?      // Translation (if available in the file)

    // Custom coding keys to handle optional translation
    enum CodingKeys: String, CodingKey {
        case id, text, translation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.translation = try? container.decode(String.self, forKey: .translation)
    }

    init(id: Int, text: String, translation: String? = nil) {
        self.id = id
        self.text = text
        self.translation = translation
    }
}

// Represents a Surah (Chapter) in the Quran
struct Surah: Codable, Identifiable, Equatable {
    let id: Int
    let name: String                 // Arabic name (e.g., "الفاتحة")
    let transliteration: String      // English transliteration (e.g., "Al-Fatihah")
    let translation: String?         // English translation (e.g., "The Opener") - optional for Arabic-only files
    let type: String                 // "meccan" or "medinan"
    let total_verses: Int            // Total number of verses in this Surah
    let verses: [Verse]              // Array of verses

    // Custom coding keys to handle optional translation
    enum CodingKeys: String, CodingKey {
        case id, name, transliteration, translation, type, total_verses, verses
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.transliteration = try container.decode(String.self, forKey: .transliteration)
        self.translation = try? container.decode(String.self, forKey: .translation)
        self.type = try container.decode(String.self, forKey: .type)
        self.total_verses = try container.decode(Int.self, forKey: .total_verses)
        self.verses = try container.decode([Verse].self, forKey: .verses)
    }

    init(id: Int, name: String, transliteration: String, translation: String?, type: String, total_verses: Int, verses: [Verse]) {
        self.id = id
        self.name = name
        self.transliteration = transliteration
        self.translation = translation
        self.type = type
        self.total_verses = total_verses
        self.verses = verses
    }

    // Computed property for display
    var typeCapitalized: String {
        return type.capitalized
    }

    var displayName: String {
        return "\(id). \(transliteration)"
    }

    var fullDisplayName: String {
        if let translation = translation {
            return "\(transliteration) - \(translation)"
        }
        return transliteration
    }
}

// Represents chapter metadata (lightweight version without verses)
struct ChapterMetadata: Codable, Identifiable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: String
    let total_verses: Int
    let link: String?               // Optional URL to chapter JSON

    enum CodingKeys: String, CodingKey {
        case id, name, transliteration, translation, type, total_verses, link
    }
}
