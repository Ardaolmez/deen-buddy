//
//  LargePrayerWidget.swift
//  Home Screen Large Widget
//

import SwiftUI
import WidgetKit

struct LargePrayerWidget: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(WidgetStrings.prayerTimes)
                            .font(.headline)
                        Text("\(entry.city), \(entry.country)")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                }
                .foregroundColor(.white)

                Divider()
                    .background(.white.opacity(0.3))

                // Next prayer (large)
                VStack(spacing: 8) {
                    Text(WidgetStrings.nextPrayer)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    Image(systemName: entry.prayerIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.white)

                    Text(entry.prayerName)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text(entry.prayerTime, style: .time)
                        .font(.title2)
                        .foregroundColor(.white)

                    // Countdown
                    Text(entry.prayerTime, style: .relative)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Divider()
                    .background(.white.opacity(0.3))

                // All prayers list
                VStack(spacing: 8) {
                    ForEach(entry.allPrayers, id: \.prayerKey) { prayer in
                        HStack {
                            Image(systemName: prayer.icon)
                                .frame(width: 24)
                            Text(WidgetStrings.prayerName(for: prayer.prayerKey))
                            Spacer()
                            Text(prayer.time, style: .time)
                                .font(.callout.bold())
                            if prayer.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .font(.callout)
                        .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }

}
