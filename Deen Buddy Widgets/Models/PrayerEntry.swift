//
//  PrayerEntry.swift
//  Deen Buddy Widgets
//
//  Timeline entry for prayer widget
//

import WidgetKit
import Foundation

struct PrayerEntry: TimelineEntry {
    let date: Date                  // When to show this entry
    let prayerKey: String           // "fajr", "dhuhr", etc.
    let prayerTime: Date
    let prayerIcon: String
    let city: String
    let country: String
    let allPrayers: [PrayerInfo]

    // Get prayer name (hardcoded English)
    var prayerName: String {
        WidgetStrings.prayerName(for: prayerKey)
    }
}
