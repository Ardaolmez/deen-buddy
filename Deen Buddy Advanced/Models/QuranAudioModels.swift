//
//  QuranAudioModels.swift
//  Deen Buddy Advanced
//
//  Data models for Quran audio recitation
//  - Arabic audio: Quran.com API (multiple reciters)
//  - English audio: AlQuran.cloud API (Ibrahim Walk - Sahih International)
//

import Foundation

// MARK: - Audio Language & Mode

/// Language options for audio playback
enum AudioLanguage: String, CaseIterable, Codable {
    case arabic = "ar"
    case english = "en"
    case turkish = "tr"

    var displayName: String {
        switch self {
        case .arabic: return "Arabic"
        case .english: return "English"
        case .turkish: return "Turkish"
        }
    }
}

/// Audio playback modes
enum AudioPlaybackMode: String, CaseIterable, Codable {
    case arabicOnly = "arabic"
    case translationOnly = "translation"
    case arabicThenTranslation = "sequential"

    var displayName: String {
        switch self {
        case .arabicOnly: return "Arabic Only"
        case .translationOnly: return "Translation Only"
        case .arabicThenTranslation: return "Arabic → Translation"
        }
    }

    var icon: String {
        switch self {
        case .arabicOnly: return "🇸🇦"
        case .translationOnly: return "🌐"
        case .arabicThenTranslation: return "➡️"
        }
    }
}

// MARK: - English Audio (AlQuran.cloud)

/// English translation audio configuration
/// Uses Ibrahim Walk reciting Sahih International translation
struct EnglishAudioConfig {
    /// Base URL for AlQuran.cloud audio CDN
    static let baseURL = "https://cdn.alquran.cloud/media/audio/ayah"

    /// Edition identifier for Ibrahim Walk (Sahih International)
    static let edition = "en.walk"

    /// Get audio URL for a specific verse
    /// - Parameter absoluteVerseNumber: The verse number from 1-6236
    /// - Returns: Full URL to the audio file
    static func audioURL(for absoluteVerseNumber: Int) -> String {
        return "\(baseURL)/\(edition)/\(absoluteVerseNumber)"
    }

    /// Get audio URL using surah and verse numbers
    /// - Parameters:
    ///   - surah: Surah number (1-114)
    ///   - verse: Verse number within the surah
    /// - Returns: Full URL to the audio file
    static func audioURL(surah: Int, verse: Int) -> String {
        let absolute = QuranVerseHelper.absoluteVerseNumber(surah: surah, verse: verse)
        return audioURL(for: absolute)
    }
}

/// Helper for verse number calculations
struct QuranVerseHelper {
    /// Total verses per surah (1-114)
    static let versesPerSurah = [
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109,    // 1-10
        123, 111, 43, 52, 99, 128, 111, 110, 98, 135,     // 11-20
        112, 78, 118, 64, 77, 227, 93, 88, 69, 60,        // 21-30
        34, 30, 73, 54, 45, 83, 182, 88, 75, 85,          // 31-40
        54, 53, 89, 59, 37, 35, 38, 29, 18, 45,           // 41-50
        60, 49, 62, 55, 78, 96, 29, 22, 24, 13,           // 51-60
        14, 11, 11, 18, 12, 12, 30, 52, 52, 44,           // 61-70
        28, 28, 20, 56, 40, 31, 50, 40, 46, 42,           // 71-80
        29, 19, 36, 25, 22, 17, 19, 26, 30, 20,           // 81-90
        15, 21, 11, 8, 8, 19, 5, 8, 8, 11,                // 91-100
        11, 8, 3, 9, 5, 4, 7, 3, 6, 3,                    // 101-110
        5, 4, 5, 6                                         // 111-114
    ]

    /// Total verses in the Quran
    static let totalVerses = 6236

    /// Convert surah:verse to absolute verse number (1-6236)
    /// - Parameters:
    ///   - surah: Surah number (1-114)
    ///   - verse: Verse number within the surah
    /// - Returns: Absolute verse number
    static func absoluteVerseNumber(surah: Int, verse: Int) -> Int {
        guard surah >= 1 && surah <= 114 else { return 1 }

        var absolute = 0
        for i in 0..<(surah - 1) {
            absolute += versesPerSurah[i]
        }
        return absolute + verse
    }

    /// Convert absolute verse number to surah:verse
    /// - Parameter absolute: Absolute verse number (1-6236)
    /// - Returns: Tuple of (surah, verse)
    static func surahAndVerse(from absolute: Int) -> (surah: Int, verse: Int) {
        var remaining = absolute
        for (index, count) in versesPerSurah.enumerated() {
            if remaining <= count {
                return (surah: index + 1, verse: remaining)
            }
            remaining -= count
        }
        return (surah: 114, verse: 6) // Last verse of Quran
    }

    /// Get total verses in a surah
    /// - Parameter surah: Surah number (1-114)
    /// - Returns: Number of verses in the surah
    static func verseCount(for surah: Int) -> Int {
        guard surah >= 1 && surah <= 114 else { return 0 }
        return versesPerSurah[surah - 1]
    }
}

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

// MARK: - Daily Verse Audio Preference

/// User's preferred audio mode for daily verse playback
enum DailyVerseAudioPreference: String, CaseIterable, Codable {
    case arabicOnly = "arabic_only"
    case translationOnly = "translation_only"
    case arabicThenTranslation = "arabic_then_translation"

    var displayName: String {
        switch self {
        case .arabicOnly: return CommonStrings.arabic
        case .translationOnly: return CommonStrings.translation
        case .arabicThenTranslation: return CommonStrings.arabicPlusTranslation
        }
    }

    var description: String {
        switch self {
        case .arabicOnly: return CommonStrings.listenToArabicRecitation
        case .translationOnly: return CommonStrings.listenToTranslation
        case .arabicThenTranslation: return CommonStrings.arabicFirstThenTranslation
        }
    }

    var icon: String {
        switch self {
        case .arabicOnly: return "speaker.wave.2.fill"
        case .translationOnly: return "globe"
        case .arabicThenTranslation: return "arrow.right.circle.fill"
        }
    }
}

// MARK: - Verse Reference Parser

/// Utility to parse verse references like "Surah Al-Baqarah 2:45" or "Al-Baqarah 2:45"
struct VerseReferenceParser {
    /// Parse a reference string and extract surah and verse numbers
    /// - Parameter reference: Reference string like "Surah Al-Baqarah 2:45"
    /// - Returns: Tuple of (surahNumber, verseNumber) if parseable, nil otherwise
    static func parse(_ reference: String?) -> (surah: Int, verse: Int)? {
        guard let reference = reference else { return nil }

        // Try to find pattern like "2:45" or "114:6"
        let pattern = #"(\d+):(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: reference, range: NSRange(reference.startIndex..., in: reference)) else {
            return nil
        }

        // Extract surah and verse numbers
        guard let surahRange = Range(match.range(at: 1), in: reference),
              let verseRange = Range(match.range(at: 2), in: reference),
              let surah = Int(reference[surahRange]),
              let verse = Int(reference[verseRange]) else {
            return nil
        }

        // Validate ranges
        guard surah >= 1, surah <= 114,
              verse >= 1, verse <= QuranVerseHelper.verseCount(for: surah) else {
            return nil
        }

        return (surah, verse)
    }
}
