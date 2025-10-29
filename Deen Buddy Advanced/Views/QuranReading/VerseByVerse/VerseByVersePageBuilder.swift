//
//  VerseByVersePageBuilder.swift
//  Deen Buddy Advanced
//
//  Page builder for verse-by-verse reading (one verse per page)
//

import Foundation

class VerseByVersePageBuilder {

    /// Builds pages with exactly one verse per page
    static func buildPages(from surahs: [Surah], startingAt position: Int = 0) -> (pages: [QuranReadingPage], startIndex: Int) {
        var pages: [QuranReadingPage] = []
        var absolutePosition = 0
        var startPageIndex = 0

        // Build one page for each verse
        for surah in surahs {
            for verse in surah.verses {
                let verseContext = VerseWithContext(
                    verse: verse,
                    surah: surah,
                    absolutePosition: absolutePosition
                )

                // Create a page with just this single verse
                let page = QuranReadingPage(
                    id: pages.count,
                    verses: [verseContext]
                )

                // Track which page contains the starting position
                if absolutePosition == position {
                    startPageIndex = pages.count
                }

                pages.append(page)
                absolutePosition += 1
            }
        }

        return (pages, startPageIndex)
    }

    /// Get current surah and verse from absolute position
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
