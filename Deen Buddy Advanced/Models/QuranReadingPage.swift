//
//  QuranReadingPage.swift
//  Deen Buddy Advanced
//
//  Model for reading pages with dynamic verse grouping
//

import Foundation

struct QuranReadingPage: Identifiable {
    let id: Int
    let verses: [VerseWithContext]

    var firstVersePosition: Int {
        verses.first?.absolutePosition ?? 0
    }

    var lastVersePosition: Int {
        verses.last?.absolutePosition ?? 0
    }
}

struct VerseWithContext: Identifiable {
    let id: String
    let verse: Verse
    let surahName: String
    let surahTransliteration: String
    let verseNumber: Int
    let absolutePosition: Int

    init(verse: Verse, surah: Surah, absolutePosition: Int) {
        self.id = "\(surah.id)-\(verse.id)"
        self.verse = verse
        self.surahName = surah.name
        self.surahTransliteration = surah.transliteration
        self.verseNumber = verse.id
        self.absolutePosition = absolutePosition
    }
}

// Helper to create pages from Quran data
class QuranPageBuilder {
    static func buildPages(from surahs: [Surah], startingAt position: Int = 0) -> (pages: [QuranReadingPage], startIndex: Int) {
        return buildAdaptivePages(from: surahs, startingAt: position, versesPerPage: 8)
    }

    static func buildAdaptivePages(from surahs: [Surah], startingAt position: Int = 0, versesPerPage: Int) -> (pages: [QuranReadingPage], startIndex: Int) {
        var pages: [QuranReadingPage] = []
        var currentPageVerses: [VerseWithContext] = []
        var currentPageId = 0
        var absolutePosition = 0
        var startPageIndex = 0

        // Build ALL pages from the beginning, not just from the starting position
        for surah in surahs {
            for verse in surah.verses {
                let verseContext = VerseWithContext(
                    verse: verse,
                    surah: surah,
                    absolutePosition: absolutePosition
                )

                // If this is the first verse of a new surah and we have verses on current page,
                // start a new page to keep surahs separate
                if verse.id == 1 && !currentPageVerses.isEmpty {
                    pages.append(QuranReadingPage(
                        id: currentPageId,
                        verses: currentPageVerses
                    ))

                    // Track which page contains the starting position
                    if absolutePosition >= position && startPageIndex == 0 {
                        startPageIndex = currentPageId
                    }

                    currentPageVerses = []
                    currentPageId += 1
                }

                currentPageVerses.append(verseContext)

                // Create a new page when we reach the limit
                if currentPageVerses.count >= versesPerPage {
                    pages.append(QuranReadingPage(
                        id: currentPageId,
                        verses: currentPageVerses
                    ))

                    // Track which page contains the starting position
                    if absolutePosition >= position && startPageIndex == 0 {
                        startPageIndex = currentPageId
                    }

                    currentPageVerses = []
                    currentPageId += 1
                }

                absolutePosition += 1
            }
        }

        // Add remaining verses as the last page
        if !currentPageVerses.isEmpty {
            pages.append(QuranReadingPage(
                id: currentPageId,
                verses: currentPageVerses
            ))

            // Check if starting position is in this last page
            if startPageIndex == 0 {
                startPageIndex = currentPageId
            }
        }

        return (pages, startPageIndex)
    }

    // Get current surah and verse from absolute position
    static func getPositionInfo(for absolutePosition: Int, in surahs: [Surah]) -> (surahId: Int, verseId: Int)? {
        var currentPos = 0

        for surah in surahs {
            if currentPos + surah.verses.count > absolutePosition {
                let verseIndex = absolutePosition - currentPos
                if verseIndex < surah.verses.count {
                    return (surah.id, surah.verses[verseIndex].id)
                }
            }
            currentPos += surah.verses.count
        }

        return nil
    }
}
