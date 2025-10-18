//
//  MediumPrayerWidget.swift
//  Home Screen Medium Widget
//

import SwiftUI
import WidgetKit

struct MediumPrayerWidget: View {
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

            HStack(spacing: 16) {
                // Left: Next prayer
                VStack(alignment: .leading, spacing: 8) {
                    Text(WidgetStrings.nextPrayer)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    HStack(spacing: 8) {
                        Image(systemName: entry.prayerIcon)
                            .font(.system(size: 28))
                        Text(entry.prayerName)
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)

                    Text(entry.prayerTime, style: .time)
                        .font(.title3)
                        .foregroundColor(.white)

                    Text("\(entry.city), \(entry.country)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Right: All prayers
                VStack(alignment: .trailing, spacing: 6) {
                    ForEach(entry.allPrayers.prefix(5), id: \.prayerKey) { prayer in
                        HStack(spacing: 4) {
                            Text(WidgetStrings.prayerName(for: prayer.prayerKey))
                                .font(.caption)
                            Text(prayer.time, style: .time)
                                .font(.caption.bold())
                            if prayer.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }

}
