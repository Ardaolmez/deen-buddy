//
//  QuranAudioModels.swift
//  Deen Buddy Advanced
//
//  Data models for Quran audio recitation from Quran.com API
//

import Foundation

// MARK: - Reciter Models

struct Reciter: Codable, Identifiable, Equatable {
    let id: Int
    let reciterName: String
    let style: String?
    let translatedName: TranslatedName?

    enum CodingKeys: String, CodingKey {
        case id
        case reciterName = "reciter_name"
        case style
        case translatedName = "translated_name"
    }

    var displayName: String {
        translatedName?.name ?? reciterName
    }

    var fullDisplayName: String {
        if let style = style, !style.isEmpty {
            return "\(displayName) - \(style)"
        }
        return displayName
    }
}

struct TranslatedName: Codable, Equatable {
    let name: String
    let languageName: String

    enum CodingKeys: String, CodingKey {
        case name
        case languageName = "language_name"
    }
}

struct RecitersResponse: Codable {
    let recitations: [Reciter]
}

// MARK: - Audio Verse Models

struct AudioVerse: Codable, Identifiable, Equatable {
    let id: Int
    let verseNumber: Int
    let verseKey: String
    let audio: VerseAudio

    enum CodingKeys: String, CodingKey {
        case id
        case verseNumber = "verse_number"
        case verseKey = "verse_key"
        case audio
    }

    var surahNumber: Int {
        let components = verseKey.split(separator: ":")
        return Int(components.first ?? "1") ?? 1
    }
}

struct VerseAudio: Codable, Equatable {
    let url: String
    let segments: [[Int]]?

    // Convert relative URL to full CDN URL
    var fullURL: String {
        if url.hasPrefix("http") {
            return url
        }
        return "https://verses.quran.com/\(url)"
    }
}

struct VersesAudioResponse: Codable {
    let verses: [AudioVerse]
}

// MARK: - Playback State

enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)

    var isPlaying: Bool {
        if case .playing = self { return true }
        return false
    }

    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }
}
