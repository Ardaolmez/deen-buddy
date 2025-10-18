//
//  QuranDataHelper.swift
//  Deen Buddy Widgets
//
//  Helper for loading and selecting random Quran verses
//

import Foundation

struct QuranDataHelper {

    // Quran JSON structure
    private struct Surah: Codable {
        let id: Int
        let transliteration: String
        let translation: String
        let total_verses: Int
        let verses: [Verse]
    }

    private struct Verse: Codable {
        let id: Int
        let translation: String
    }

    /// Get a random verse from Quran
    /// - Parameter seed: Optional seed for consistent randomization (e.g., for daily verse)
    static func getRandomVerse(seed: UInt64? = nil) -> VerseWidgetData? {
        guard let surahs = loadQuranData() else { return nil }

        var randomGenerator: RandomNumberGenerator
        if let seed = seed {
            randomGenerator = SeededRandomNumberGenerator(seed: seed)
        } else {
            randomGenerator = SystemRandomNumberGenerator()
        }

        // Pick random surah
        guard let randomSurah = surahs.randomElement(using: &randomGenerator),
              !randomSurah.verses.isEmpty else {
            return nil
        }

        // Pick random verse from that surah
        guard let randomVerse = randomSurah.verses.randomElement(using: &randomGenerator) else {
            return nil
        }

        return VerseWidgetData(
            verseText: randomVerse.translation,
            surahName: randomSurah.transliteration,
            surahNumber: randomSurah.id,
            verseNumber: randomVerse.id,
            lastUpdated: Date()
        )
    }

    /// Get daily verse (same verse all day)
    static func getDailyVerse() -> VerseWidgetData? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let seed = UInt64(startOfDay.timeIntervalSince1970)
        return getRandomVerse(seed: seed)
    }

    /// Get hourly verse (same verse for current hour)
    static func getHourlyVerse() -> VerseWidgetData? {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: now)
        guard let hourStart = Calendar.current.date(from: components) else {
            return getRandomVerse()
        }
        let seed = UInt64(hourStart.timeIntervalSince1970)
        return getRandomVerse(seed: seed)
    }

    // MARK: - Private Helpers

    private static func loadQuranData() -> [Surah]? {
        guard let url = Bundle.main.url(forResource: "quran_en", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let surahs = try? JSONDecoder().decode([Surah].self, from: data) else {
            return nil
        }
        return surahs
    }
}

/// Seeded random number generator for consistent randomization
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
