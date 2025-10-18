//
//  WidgetStrings.swift
//  Deen Buddy Widgets
//
//  Hardcoded strings for widgets (matching main app pattern)
//

import Foundation

struct WidgetStrings {
    // Prayer Names
    static let fajr = "Fajr"
    static let dhuhr = "Dhuhr"
    static let asr = "Asr"
    static let maghrib = "Maghrib"
    static let isha = "Isha"

    // Widget UI
    static let nextPrayer = "Next Prayer"
    static let prayerTimes = "Prayer Times"
    static let todaysPrayers = "Today's Prayers"
    static let completed = "Completed"
    static let loading = "Loading..."
    static let noData = "Open app to load prayer times"

    // Widget Configuration (shown in widget gallery)
    static let widgetName = "Prayer Times"
    static let widgetDescription = "Shows next prayer time and countdown"

    // Quran Verse Widget Strings
    static let verseOfTheDay = "Verse of the Day"
    static let verseOfTheHour = "Verse of the Hour"
    static let dailyVerseWidgetName = "Daily Verse"
    static let dailyVerseWidgetDescription = "A new verse every day"
    static let hourlyVerseWidgetName = "Hourly Verse"
    static let hourlyVerseWidgetDescription = "A new verse every hour"
    static let quranVerse = "Quran Verse"

    // Helper to get prayer name from key
    static func prayerName(for key: String) -> String {
        switch key.lowercased() {
        case "fajr": return fajr
        case "dhuhr": return dhuhr
        case "asr": return asr
        case "maghrib": return maghrib
        case "isha": return isha
        default: return key.capitalized
        }
    }
}
