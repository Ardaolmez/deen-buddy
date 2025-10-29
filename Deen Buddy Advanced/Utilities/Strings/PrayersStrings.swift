//
//  PrayersStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Prayers tab
//

import Foundation

struct PrayersStrings {
    static let navigationTitle = "Prayers"
    static let myPrayers = "My Prayers"
    static let todaysPrayers = "Today's Prayers"
    static let didYouPray = "Did you pray %@?"
    static let greatJob = "Great job!"
    static let markedCompleted = "Marked as completed for today."
    static let markCompleted = "Mark it completed to track your consistency."
    static let current = "current"
    static let now = "Now"
    static let next = "Next"
    static let nextPrayer = "Upcoming"
    static let nextPrayerAt = "Next: %@ at %@"
    static let nextPrayerTomorrow = "Next: %@ tomorrow"
    static let beforeFajr = "Before Fajr"
    static let sunrise = "Sunrise"
    static let sunset = "Sunset"
    static let zawal = "Zawal"
    static let undo = "Undo"
    static let yes = "Yes"
    static let history = "Stats"
    static let prayerStreakTitle = "Weekly Streak"
    static let streakPerfect = "Perfect so far — keep it up!"
    static let streakSoFarFormat = "Streaks this month: %@"
    static let availableLater = "Available when time comes"
    static let allComplete = "All Complete"
    static let perfect = "Perfect!"
    
    // "Next: Dhuhr — 1:05 PM"
            static let nextDhuhrCompact = "Next: %@ — %@"

            // "Now: Asr — 4:22 PM"
            static let nowPrayerCompact = "Now: %@ — %@"
    
    

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

    // MARK: - Qibla Compass
    static let qiblaDirection = "Qibla Direction"
    static let alignedToQibla = "Face to Qibla"
    static let turnDirectionFormat = "Turn %@ %d°" // "Turn 75° left"
    static let left = "left"
    static let right = "right"
    static let device = "Device"
    static let currentHeading = "Current Heading"
    static let difference = "Difference"
    static let gettingLocation = "Getting location..."
    static let lowAccuracyWarning = "Low compass accuracy - calibrate your device"
}

// MARK: - Arrow Qibla Compass Strings (Deprecated - use AppStrings.prayers instead)
struct ArrowQiblaStrings {
    // Direction texts
    static let alignedToQibla = AppStrings.prayers.alignedToQibla
    static let turnDirectionFormat = AppStrings.prayers.turnDirectionFormat
    static let left = AppStrings.prayers.left
    static let right = AppStrings.prayers.right

    // Labels
    static let device = AppStrings.prayers.device
    static let qiblaDirection = AppStrings.prayers.qiblaDirection
    static let currentHeading = AppStrings.prayers.currentHeading
    static let difference = AppStrings.prayers.difference

    // Status messages
    static let gettingLocation = AppStrings.prayers.gettingLocation
    static let lowAccuracyWarning = AppStrings.prayers.lowAccuracyWarning
}
