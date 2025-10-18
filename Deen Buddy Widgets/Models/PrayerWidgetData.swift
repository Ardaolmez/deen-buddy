//
//  PrayerWidgetData.swift
//  Deen Buddy Widgets
//
//  Shared data models for widget
//

import Foundation

/// Individual prayer information
struct PrayerInfo: Codable {
    let prayerKey: String               // "fajr", "dhuhr", etc.
    let time: Date
    let icon: String
    let isCompleted: Bool               // For showing checkmarks
}

/// Main data structure shared between app and widget
struct PrayerWidgetData: Codable {
    let nextPrayerKey: String           // "fajr", "dhuhr", etc.
    let nextPrayerTime: Date
    let nextPrayerIcon: String          // SF Symbol name
    let city: String
    let country: String
    let allPrayers: [PrayerInfo]        // All 5 daily prayers
    let lastUpdated: Date
}
