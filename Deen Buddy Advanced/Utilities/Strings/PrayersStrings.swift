//
//  PrayersStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Prayers tab
//

import Foundation

private let table = "Prayers"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct PrayersStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var myPrayers: String { lang.getString("myPrayers", table: table) }
    static var todaysPrayers: String { lang.getString("todaysPrayers", table: table) }
    static var didYouPray: String { lang.getString("didYouPray", table: table) }
    static var greatJob: String { lang.getString("greatJob", table: table) }
    static var markedCompleted: String { lang.getString("markedCompleted", table: table) }
    static var markCompleted: String { lang.getString("markCompleted", table: table) }
    static var current: String { lang.getString("current", table: table) }
    static var now: String { lang.getString("now", table: table) }
    static var next: String { lang.getString("next", table: table) }
    static var nextPrayer: String { lang.getString("nextPrayer", table: table) }
    static var nextPrayerAt: String { lang.getString("nextPrayerAt", table: table) }
    static var nextPrayerTomorrow: String { lang.getString("nextPrayerTomorrow", table: table) }
    static var beforeFajr: String { lang.getString("beforeFajr", table: table) }
    static var sunrise: String { lang.getString("sunrise", table: table) }
    static var sunset: String { lang.getString("sunset", table: table) }
    static var zawal: String { lang.getString("zawal", table: table) }
    static var undo: String { lang.getString("undo", table: table) }
    static var yes: String { lang.getString("yes", table: table) }
    static var history: String { lang.getString("history", table: table) }
    static var prayerStreakTitle: String { lang.getString("prayerStreakTitle", table: table) }
    static var streakPerfect: String { lang.getString("streakPerfect", table: table) }
    static var streakSoFarFormat: String { lang.getString("streakSoFarFormat", table: table) }
    static var availableLater: String { lang.getString("availableLater", table: table) }
    static var allComplete: String { lang.getString("allComplete", table: table) }
    static var perfect: String { lang.getString("perfect", table: table) }

    // Compact Prayer Status
    static var nextDhuhrCompact: String { lang.getString("nextDhuhrCompact", table: table) }
    static var nowPrayerCompact: String { lang.getString("nowPrayerCompact", table: table) }

    // Prayer Names
    static var fajr: String { lang.getString("fajr", table: table) }
    static var dhuhr: String { lang.getString("dhuhr", table: table) }
    static var asr: String { lang.getString("asr", table: table) }
    static var maghrib: String { lang.getString("maghrib", table: table) }
    static var isha: String { lang.getString("isha", table: table) }

    // Prayer Names (Short)
    static var fajrShort: String { lang.getString("fajrShort", table: table) }
    static var dhuhrShort: String { lang.getString("dhuhrShort", table: table) }
    static var asrShort: String { lang.getString("asrShort", table: table) }
    static var maghribShort: String { lang.getString("maghribShort", table: table) }
    static var ishaShort: String { lang.getString("ishaShort", table: table) }

    // Time formats
    static var timePlaceholder: String { lang.getString("timePlaceholder", table: table) }
    static var timeCountdownPlaceholder: String { lang.getString("timeCountdownPlaceholder", table: table) }

    // Format Strings
    static var nowPrayerFormat: String { lang.getString("nowPrayerFormat", table: table) }
    static var nextDhuhrFormat: String { lang.getString("nextDhuhrFormat", table: table) }

    // Location & Status
    static var locating: String { lang.getString("locating", table: table) }
    static var yourArea: String { lang.getString("yourArea", table: table) }
    static var countdownPlaceholder: String { lang.getString("countdownPlaceholder", table: table) }

    // UserDefaults Keys (not localized)
    static let completedKeyPrefix = "prayers.completed"

    // MARK: - Qibla Compass
    static var qiblaDirection: String { lang.getString("qiblaDirection", table: table) }
    static var alignedToQibla: String { lang.getString("alignedToQibla", table: table) }
    static var turnDirectionFormat: String { lang.getString("turnDirectionFormat", table: table) }
    static var left: String { lang.getString("left", table: table) }
    static var right: String { lang.getString("right", table: table) }
    static var device: String { lang.getString("device", table: table) }
    static var currentHeading: String { lang.getString("currentHeading", table: table) }
    static var difference: String { lang.getString("difference", table: table) }
    static var gettingLocation: String { lang.getString("gettingLocation", table: table) }
    static var lowAccuracyWarning: String { lang.getString("lowAccuracyWarning", table: table) }

    // MARK: - Madhab
    static var madhabShafi: String { lang.getString("madhabShafi", table: table) }
    static var madhabHanafi: String { lang.getString("madhabHanafi", table: table) }
    static var madhabShafiDesc: String { lang.getString("madhabShafiDesc", table: table) }
    static var madhabHanafiDesc: String { lang.getString("madhabHanafiDesc", table: table) }
}

// MARK: - Arrow Qibla Compass Strings (Deprecated - use AppStrings.prayers instead)
struct ArrowQiblaStrings {
    // Direction texts
    static var alignedToQibla: String { AppStrings.prayers.alignedToQibla }
    static var turnDirectionFormat: String { AppStrings.prayers.turnDirectionFormat }
    static var left: String { AppStrings.prayers.left }
    static var right: String { AppStrings.prayers.right }

    // Labels
    static var device: String { AppStrings.prayers.device }
    static var qiblaDirection: String { AppStrings.prayers.qiblaDirection }
    static var currentHeading: String { AppStrings.prayers.currentHeading }
    static var difference: String { AppStrings.prayers.difference }

    // Status messages
    static var gettingLocation: String { AppStrings.prayers.gettingLocation }
    static var lowAccuracyWarning: String { AppStrings.prayers.lowAccuracyWarning }
}
