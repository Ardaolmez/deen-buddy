//
//  PrayerWidgetData.swift
//  Shared between main app and widget
//
//  Created for Deen Buddy Advanced
//

import Foundation

/// Data model shared between app and widget
struct PrayerWidgetData: Codable {
    // Next prayer info
    let nextPrayerKey: String           // "fajr", "dhuhr", etc. (for localization)
    let nextPrayerTime: Date            // Prayer time
    let nextPrayerIcon: String          // "sunrise.fill", etc.

    // Location
    let city: String                    // "Toronto"
    let country: String                 // "CA"

    // All prayers today
    let allPrayers: [PrayerInfo]

    // Metadata
    let lastUpdated: Date
}

struct PrayerInfo: Codable {
    let prayerKey: String               // "fajr", "dhuhr" (for localization)
    let time: Date
    let icon: String
    let isCompleted: Bool               // For showing checkmarks
}
