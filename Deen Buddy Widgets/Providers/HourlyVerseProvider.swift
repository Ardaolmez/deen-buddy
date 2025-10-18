//
//  HourlyVerseProvider.swift
//  Deen Buddy Widgets
//
//  Timeline provider for hourly verse widget
//

import WidgetKit
import SwiftUI

struct HourlyVerseProvider: TimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> VerseEntry {
        createFallbackEntry(date: Date())
    }

    // MARK: - Snapshot

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        let entry = createEntry(from: Date())
        completion(entry)
    }

    // MARK: - Timeline

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        let now = Date()
        let entry = createEntry(from: now)

        // Refresh at the next hour
        let calendar = Calendar.current
        let nextHour = calendar.date(byAdding: .hour, value: 1, to: now)!
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: nextHour)
        let nextHourStart = calendar.date(from: components)!

        let timeline = Timeline(entries: [entry], policy: .after(nextHourStart))
        completion(timeline)
    }

    // MARK: - Helpers

    private func createEntry(from date: Date) -> VerseEntry {
        guard let verse = QuranDataHelper.getHourlyVerse() else {
            return createFallbackEntry(date: date)
        }

        return VerseEntry(
            date: date,
            verseText: verse.verseText,
            surahName: verse.surahName,
            surahNumber: verse.surahNumber,
            verseNumber: verse.verseNumber
        )
    }

    private func createFallbackEntry(date: Date) -> VerseEntry {
        VerseEntry(
            date: date,
            verseText: WidgetStrings.loading,
            surahName: "",
            surahNumber: 1,
            verseNumber: 1
        )
    }
}
