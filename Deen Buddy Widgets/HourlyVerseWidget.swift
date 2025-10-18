//
//  HourlyVerseWidget.swift
//  Deen Buddy Widgets
//
//  Hourly verse widget definition
//

import WidgetKit
import SwiftUI

struct HourlyVerseWidget: Widget {
    let kind: String = "HourlyVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: HourlyVerseProvider()
        ) { entry in
            VerseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.hourlyVerseWidgetName)
        .description(WidgetStrings.hourlyVerseWidgetDescription)
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

// Widget Entry View (routes to correct size)
struct VerseWidgetEntryView: View {
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
#Preview(as: .systemSmall) {
    HourlyVerseWidget()
} timeline: {
    VerseEntry(
        date: .now,
        verseText: "Indeed, with hardship comes ease.",
        surahName: "Ash-Sharh",
        surahNumber: 94,
        verseNumber: 6
    )
}
