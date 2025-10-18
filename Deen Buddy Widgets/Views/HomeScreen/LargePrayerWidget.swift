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
                        colors: [AppColors.Widget.prayerBackgroundStart, AppColors.Widget.prayerBackgroundEnd],
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
                .foregroundColor(AppColors.Widget.prayerPrimaryText)

                Divider()
                    .background(AppColors.Widget.prayerDivider)

                // Next prayer (large)
                VStack(spacing: 8) {
                    Text(WidgetStrings.nextPrayer)
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.prayerSecondaryText)

                    Image(systemName: entry.prayerIcon)
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)

                    Text(entry.prayerName)
                        .font(.title.bold())
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)

                    Text(entry.prayerTime, style: .time)
                        .font(.title2)
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)

                    // Countdown
                    Text(entry.prayerTime, style: .relative)
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.prayerSecondaryText)
                }

                Divider()
                    .background(AppColors.Widget.prayerDivider)

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
                                    .foregroundColor(AppColors.Widget.prayerCheckmark)
                            }
                        }
                        .font(.callout)
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)
                    }
                }
            }
            .padding()
        }
    }

}
