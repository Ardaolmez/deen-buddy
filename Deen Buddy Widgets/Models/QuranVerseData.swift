//
//  QuranVerseData.swift
//  Deen Buddy Widgets
//
//  Quran verse models for widgets
//

import Foundation
import WidgetKit

/// Data structure for storing verse information
struct VerseWidgetData: Codable {
    let verseText: String           // English translation
    let surahName: String            // "Al-Fatiha"
    let surahNumber: Int             // 1
    let verseNumber: Int             // 1
    let lastUpdated: Date
}

/// Timeline entry for verse widgets
struct VerseEntry: TimelineEntry {
    let date: Date                  // When to show this entry
    let verseText: String
    let surahName: String
    let surahNumber: Int
    let verseNumber: Int

    // Formatted reference: "Al-Fatiha (1:1)"
    var verseReference: String {
        "\(surahName) (\(surahNumber):\(verseNumber))"
    }
}
