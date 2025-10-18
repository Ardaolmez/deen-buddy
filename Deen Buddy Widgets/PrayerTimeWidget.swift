//
//  PrayerTimeWidget.swift
//  Main widget definition
//

import WidgetKit
import SwiftUI

struct PrayerTimeWidget: Widget {
    let kind: String = "PrayerTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: PrayerTimelineProvider()
        ) { entry in
            PrayerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.widgetName)
        .description(WidgetStrings.widgetDescription)
        .supportedFamilies([
            // Home Screen
            .systemSmall,
            .systemMedium,
            .systemLarge,

            // Lock Screen (iOS 16+)
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }

}

// Widget Entry View (routes to correct size)
struct PrayerWidgetEntryView: View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        // Home Screen
        case .systemSmall:
            SmallPrayerWidget(entry: entry)
        case .systemMedium:
            MediumPrayerWidget(entry: entry)
        case .systemLarge:
            LargePrayerWidget(entry: entry)

        // Lock Screen
        case .accessoryCircular:
            CircularPrayerWidget(entry: entry)
        case .accessoryRectangular:
            RectangularPrayerWidget(entry: entry)
        case .accessoryInline:
            InlinePrayerWidget(entry: entry)

        default:
            SmallPrayerWidget(entry: entry)
        }
    }
}

// Previews
#Preview(as: .systemSmall) {
    PrayerTimeWidget()
} timeline: {
    PrayerEntry(
        date: .now,
        prayerKey: "maghrib",
        prayerTime: Date().addingTimeInterval(3600),
        prayerIcon: "sunset.fill",
        city: "Toronto",
        country: "CA",
        allPrayers: []
    )
}
