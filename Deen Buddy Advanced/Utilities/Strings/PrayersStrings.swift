//
//  PrayersStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Prayers tab
//

import Foundation

struct PrayersStrings {
    static let navigationTitle = "Prayers"
    static let todaysPrayers = "Today's Prayers"
    static let didYouPray = "Did you pray %@?"
    static let greatJob = "Great job!"
    static let markedCompleted = "Marked as completed for today."
    static let markCompleted = "Mark it completed to track your consistency."
    static let current = "current"
    static let now = "Now"
    static let next = "Next"
    static let nextPrayerAt = "Next: %@ at %@"
    static let nextPrayerTomorrow = "Next: %@ tomorrow"
    static let beforeFajr = "Before Fajr"
    static let sunrise = "Sunrise"
    static let sunset = "Sunset"
    static let zawal = "Zawal"
    static let undo = "Undo"
    static let yes = "Yes"
    static let history = "Stats"
    
    

    // Prayer Names
    static let dhuhr = "Dhuhr"

    // Time formats
    static let timePlaceholder = "--:--"
    static let timeCountdownPlaceholder = "--:--:--"

    // Format Strings
    static let nowPrayerFormat = "%@: %@ — %@"  // "Now: Fajr — 5:30 AM"
    static let nextDhuhrFormat = "%@: %@ — %@"  // "Next: Dhuhr — 12:15 PM"

    // Location & Status
    static let locating = "Locating…"
    static let yourArea = "Your Area"
    static let countdownPlaceholder = "—"

    // UserDefaults Keys
    static let completedKeyPrefix = "prayers.completed"
}
