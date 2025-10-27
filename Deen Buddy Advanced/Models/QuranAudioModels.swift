//
//  QuranAudioModels.swift
//  Deen Buddy Advanced
//
//  Models for Quran audio playback functionality
//

import Foundation

// MARK: - Audio Language
enum AudioLanguage: String, CaseIterable, Codable {
    case arabic = "Arabic"
    case english = "English"
    case both = "Both"

    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Audio Reciter
struct AudioReciter: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let language: AudioLanguage
    let basePath: String  // Base path for audio files

    static let reciters: [AudioReciter] = [
        AudioReciter(
            id: "alafasy",
            name: "Mishary Rashid Alafasy",
            language: .arabic,
            basePath: "Arabic/Alafasy"
        ),
        AudioReciter(
            id: "ibrahim_walk",
            name: "Ibrahim Walk (English Translation)",
            language: .english,
            basePath: "English/IbrahimWalk"
        )
    ]

    static var defaultArabic: AudioReciter {
        return reciters.first { $0.language == .arabic } ?? reciters[0]
    }

    static var defaultEnglish: AudioReciter {
        return reciters.first { $0.language == .english } ?? reciters[1]
    }
}

// MARK: - Playback State
enum PlaybackState: Equatable {
    case stopped
    case playing
    case paused
    case loading
    case error(String)
}

// MARK: - Audio Playback Info
struct AudioPlaybackInfo: Equatable {
    let surahId: Int
    let verseId: Int
    let reciter: AudioReciter
    let language: AudioLanguage

    // Generate file path for this audio
    func audioFilePath() -> String {
        switch language {
        case .arabic:
            // Format: 001001.mp3 (3-digit surah + 3-digit verse)
            let surahString = String(format: "%03d", surahId)
            let verseString = String(format: "%03d", verseId)
            return "\(reciter.basePath)/\(surahString)/\(verseString).mp3"

        case .english:
            // English audio is by chapter, not verse
            let surahString = String(format: "%03d", surahId)
            return "\(reciter.basePath)/\(surahString).mp3"

        case .both:
            // Return Arabic path for verse-by-verse (English can be handled separately)
            let surahString = String(format: "%03d", surahId)
            let verseString = String(format: "%03d", verseId)
            return "\(reciter.basePath)/\(surahString)/\(verseString).mp3"
        }
    }
}
