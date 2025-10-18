//
//  PrayerTimelineProvider.swift
//  Deen Buddy Widgets
//
//  Timeline provider for prayer widgets
//

import WidgetKit
import SwiftUI
import Foundation

struct PrayerTimelineProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            prayerKey: "loading",
            prayerTime: Date(),
            prayerIcon: "moon.stars.fill",
            city: "",
            country: "",
            allPrayers: []
        )
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        let entry = createEntry(from: Date())
        completion(entry)
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        guard let data = UserDefaults.shared.loadPrayerData() else {
            // No data - show placeholder and retry in 5 minutes
            let entry = placeholder(in: context)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
            completion(timeline)
            return
        }

        var entries: [PrayerEntry] = []
        let now = Date()

        // Add current entry
        entries.append(createEntry(from: now, data: data))

        // Add future entries at each prayer time
        for prayer in data.allPrayers where prayer.time > now {
            entries.append(createEntry(from: prayer.time, data: data))
        }

        // Refresh after next prayer time
        let nextRefresh = data.nextPrayerTime
        let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }

    // MARK: - Helpers

    private func createEntry(from date: Date, data: PrayerWidgetData? = nil) -> PrayerEntry {
        guard let data = data else {
            return PrayerEntry(
                date: date,
                prayerKey: "loading",
                prayerTime: date,
                prayerIcon: "moon.stars.fill",
                city: "",
                country: "",
                allPrayers: []
            )
        }

        // Find next prayer from current time
        let nextPrayer = data.allPrayers.first { $0.time > date } ?? data.allPrayers.first!

        return PrayerEntry(
            date: date,
            prayerKey: nextPrayer.prayerKey,
            prayerTime: nextPrayer.time,
            prayerIcon: nextPrayer.icon,
            city: data.city,
            country: data.country,
            allPrayers: data.allPrayers
        )
    }
}
