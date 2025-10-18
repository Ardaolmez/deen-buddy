//
//  DailyVerseWidget.swift
//  Deen Buddy Widgets
//
//  Daily verse widget definition
//

import WidgetKit
import SwiftUI

struct DailyVerseWidget: Widget {
    let kind: String = "DailyVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: DailyVerseProvider()
        ) { entry in
            DailyVerseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.dailyVerseWidgetName)
        .description(WidgetStrings.dailyVerseWidgetDescription)
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

// Widget Entry View (routes to correct size)
struct DailyVerseWidgetEntryView: View {
    var entry: VerseEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallVerseWidget(entry: entry)
        case .systemMedium:
            MediumVerseWidget(entry: entry)
        case .systemLarge:
            LargeVerseWidget(entry: entry)
        default:
            SmallVerseWidget(entry: entry)
        }
    }
}

// Previews
#Preview(as: .systemMedium) {
    DailyVerseWidget()
} timeline: {
    VerseEntry(
        date: .now,
        verseText: "So verily, with the hardship, there is relief. Verily, with the hardship, there is relief.",
        surahName: "Ash-Sharh",
        surahNumber: 94,
        verseNumber: 5
    )
}
