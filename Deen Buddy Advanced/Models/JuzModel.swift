//
//  JuzModel.swift
//  Deen Buddy Advanced
//
//  Juz (Para) data model for Quran navigation
//

import Foundation

// Represents a Juz (Para) - 1/30th division of the Quran
struct Juz: Identifiable, Equatable {
    let id: Int  // 1-30
    let startSurah: Int
    let startVerse: Int
    let endSurah: Int
    let endVerse: Int

    var displayName: String {
        return String(format: AppStrings.quran.juzCount, id)
    }

    // Total verses in this Juz (approximate)
    var approximateVerseCount: Int {
        // Simplified calculation - each Juz has roughly 208 verses (6236/30)
        return 208
    }
}

// Juz boundaries based on standard Madani Mushaf
extension Juz {
    static let allJuz: [Juz] = [
        Juz(id: 1, startSurah: 1, startVerse: 1, endSurah: 2, endVerse: 141),
        Juz(id: 2, startSurah: 2, startVerse: 142, endSurah: 2, endVerse: 252),
        Juz(id: 3, startSurah: 2, startVerse: 253, endSurah: 3, endVerse: 92),
        Juz(id: 4, startSurah: 3, startVerse: 93, endSurah: 4, endVerse: 23),
        Juz(id: 5, startSurah: 4, startVerse: 24, endSurah: 4, endVerse: 147),
        Juz(id: 6, startSurah: 4, startVerse: 148, endSurah: 5, endVerse: 81),
        Juz(id: 7, startSurah: 5, startVerse: 82, endSurah: 6, endVerse: 110),
        Juz(id: 8, startSurah: 6, startVerse: 111, endSurah: 7, endVerse: 87),
        Juz(id: 9, startSurah: 7, startVerse: 88, endSurah: 8, endVerse: 40),
        Juz(id: 10, startSurah: 8, startVerse: 41, endSurah: 9, endVerse: 92),
        Juz(id: 11, startSurah: 9, startVerse: 93, endSurah: 11, endVerse: 5),
        Juz(id: 12, startSurah: 11, startVerse: 6, endSurah: 12, endVerse: 52),
        Juz(id: 13, startSurah: 12, startVerse: 53, endSurah: 15, endVerse: 1),
        Juz(id: 14, startSurah: 15, startVerse: 2, endSurah: 16, endVerse: 128),
        Juz(id: 15, startSurah: 17, startVerse: 1, endSurah: 18, endVerse: 74),
        Juz(id: 16, startSurah: 18, startVerse: 75, endSurah: 20, endVerse: 135),
        Juz(id: 17, startSurah: 21, startVerse: 1, endSurah: 22, endVerse: 78),
        Juz(id: 18, startSurah: 23, startVerse: 1, endSurah: 25, endVerse: 20),
        Juz(id: 19, startSurah: 25, startVerse: 21, endSurah: 27, endVerse: 55),
        Juz(id: 20, startSurah: 27, startVerse: 56, endSurah: 29, endVerse: 45),
        Juz(id: 21, startSurah: 29, startVerse: 46, endSurah: 33, endVerse: 30),
        Juz(id: 22, startSurah: 33, startVerse: 31, endSurah: 36, endVerse: 27),
        Juz(id: 23, startSurah: 36, startVerse: 28, endSurah: 39, endVerse: 31),
        Juz(id: 24, startSurah: 39, startVerse: 32, endSurah: 41, endVerse: 46),
        Juz(id: 25, startSurah: 41, startVerse: 47, endSurah: 45, endVerse: 37),
        Juz(id: 26, startSurah: 46, startVerse: 1, endSurah: 51, endVerse: 30),
        Juz(id: 27, startSurah: 51, startVerse: 31, endSurah: 57, endVerse: 29),
        Juz(id: 28, startSurah: 58, startVerse: 1, endSurah: 66, endVerse: 12),
        Juz(id: 29, startSurah: 67, startVerse: 1, endSurah: 77, endVerse: 50),
        Juz(id: 30, startSurah: 78, startVerse: 1, endSurah: 114, endVerse: 6)
    ]
}
