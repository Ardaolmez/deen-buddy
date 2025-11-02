//
//  QuranService.swift
//  Deen Buddy Advanced
//
//  Service to load and manage Quran data
//

import Foundation

class QuranService {
    static let shared = QuranService()

    private init() {}

    // Load the entire Quran based on selected language
    func loadQuran(language: QuranLanguage = LanguageManager.shared.selectedLanguage) -> [Surah] {
        let fileName = language.fileName

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ QuranService: Could not find \(fileName).json in bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let surahs = try decoder.decode([Surah].self, from: data)
            print("✅ QuranService: Loaded \(surahs.count) Surahs from \(fileName).json")
            return surahs
        } catch {
            print("❌ QuranService: Error loading Quran - \(error.localizedDescription)")
            return []
        }
    }

    // Load chapter metadata (lightweight)
    func loadChapterMetadata(language: QuranLanguage = .english) -> [ChapterMetadata] {
        let fileName = "chapters_\(language.rawValue)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ QuranService: Could not find \(fileName).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let chapters = try decoder.decode([ChapterMetadata].self, from: data)
            return chapters
        } catch {
            print("❌ QuranService: Error loading chapters - \(error)")
            return []
        }
    }

    // Get a specific Surah by ID (1-114)
    func getSurah(id: Int, from surahs: [Surah]) -> Surah? {
        return surahs.first { $0.id == id }
    }

    // Get a specific verse from a Surah
    func getVerse(surahId: Int, verseId: Int, from surahs: [Surah]) -> Verse? {
        guard let surah = getSurah(id: surahId, from: surahs) else { return nil }
        return surah.verses.first { $0.id == verseId }
    }

    // Search Surahs by name or transliteration
    func searchSurahs(query: String, in surahs: [Surah]) -> [Surah] {
        guard !query.isEmpty else { return surahs }

        return surahs.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.transliteration.localizedCaseInsensitiveContains(query) ||
            $0.translation!.localizedCaseInsensitiveContains(query)
        }
    }

    // Get daily verse based on day of year
    func getDailyVerse(surahs: [Surah]) -> (verse: Verse, surah: Surah)? {
        guard !surahs.isEmpty else { return nil }

        // Calculate day of year (1-365 or 1-366 for leap years)
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1

        // Calculate total verses in Quran
        let totalVerses = surahs.reduce(0) { $0 + $1.verses.count }
        guard totalVerses > 0 else { return nil }

        // Pick a verse index based on day of year
        let verseIndex = (dayOfYear - 1) % totalVerses

        // Find the corresponding verse and surah
        var currentIndex = 0
        for surah in surahs {
            let surahVerseCount = surah.verses.count
            if currentIndex + surahVerseCount > verseIndex {
                let verseInSurah = verseIndex - currentIndex
                return (verse: surah.verses[verseInSurah], surah: surah)
            }
            currentIndex += surahVerseCount
        }

        return nil
    }

    // Get daily verse filtered by word count (4-20 words for optimal display)
    func getDailyVerseFiltered(surahs: [Surah], minWords: Int = 4, maxWords: Int = 20) -> (verse: Verse, surah: Surah)? {
        guard !surahs.isEmpty else { return nil }

        // Build list of verses that meet length criteria
        var filteredVerses: [(verse: Verse, surah: Surah)] = []

        for surah in surahs {
            for verse in surah.verses {
                // Check translation length if available, otherwise Arabic text
                let textToCheck = verse.translation ?? verse.text
                let wordCount = textToCheck.split(separator: " ").count

                // Only include verses within word count range
                if wordCount >= minWords && wordCount <= maxWords {
                    filteredVerses.append((verse: verse, surah: surah))
                }
            }
        }

        guard !filteredVerses.isEmpty else { return nil }

        // Pick based on day of year (consistent each day)
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % filteredVerses.count

        return filteredVerses[index]
    }

    // Get a random verse (optional feature)
    func getRandomVerse(from surahs: [Surah]) -> (verse: Verse, surah: Surah)? {
        guard !surahs.isEmpty else { return nil }

        let randomSurah = surahs.randomElement()!
        guard !randomSurah.verses.isEmpty else { return nil }

        let randomVerse = randomSurah.verses.randomElement()!
        return (verse: randomVerse, surah: randomSurah)
    }
}
