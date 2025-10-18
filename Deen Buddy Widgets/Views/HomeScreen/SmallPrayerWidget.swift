//
//  SmallPrayerWidget.swift
//  Home Screen Small Widget
//

import SwiftUI
import WidgetKit

struct SmallPrayerWidget: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            // Background gradient
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Content
            VStack(spacing: 8) {
                // Icon
                Image(systemName: entry.prayerIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)

                // Prayer name
                Text(entry.prayerName)
                    .font(.headline)
                    .foregroundColor(.white)

                // Time
                Text(entry.prayerTime, style: .time)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // Location
                HStack(spacing: 4) {
                    Text(entry.city)
                    if !entry.country.isEmpty {
                        Text("•")
                        Text(entry.country)
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
}
