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
                        colors: [AppColors.Widget.prayerBackgroundStart, AppColors.Widget.prayerBackgroundEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Content
            VStack(spacing: 8) {
                // Icon
                Image(systemName: entry.prayerIcon)
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.Widget.prayerPrimaryText)

                // Prayer name
                Text(entry.prayerName)
                    .font(.headline)
                    .foregroundColor(AppColors.Widget.prayerPrimaryText)

                // Time
                Text(entry.prayerTime, style: .time)
                    .font(.title2.bold())
                    .foregroundColor(AppColors.Widget.prayerPrimaryText)

                // Location
                HStack(spacing: 4) {
                    Text(entry.city)
                    if !entry.country.isEmpty {
                        Text("•")
                        Text(entry.country)
                    }
                }
                .font(.caption2)
                .foregroundColor(AppColors.Widget.prayerSecondaryText)
            }
            .padding()
        }
    }
}
