//
//  DailyVerseProvider.swift
//  Deen Buddy Widgets
//
//  Timeline provider for daily verse widget
//

import WidgetKit
import SwiftUI

struct DailyVerseProvider: TimelineProvider {

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

        // Refresh at midnight tomorrow
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let nextMidnight = calendar.startOfDay(for: tomorrow)

        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    // MARK: - Helpers

    private func createEntry(from date: Date) -> VerseEntry {
        guard let verse = QuranDataHelper.getDailyVerse() else {
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
