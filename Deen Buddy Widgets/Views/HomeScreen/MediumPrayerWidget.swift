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
                        colors: [AppColors.Widget.prayerBackgroundStart, AppColors.Widget.prayerBackgroundEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 16) {
                // Left: Next prayer
                VStack(alignment: .leading, spacing: 8) {
                    Text(WidgetStrings.nextPrayer)
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.prayerSecondaryText)

                    HStack(spacing: 8) {
                        Image(systemName: entry.prayerIcon)
                            .font(.system(size: 28))
                        Text(entry.prayerName)
                            .font(.title2.bold())
                    }
                    .foregroundColor(AppColors.Widget.prayerPrimaryText)

                    Text(entry.prayerTime, style: .time)
                        .font(.title3)
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)

                    Text("\(entry.city), \(entry.country)")
                        .font(.caption2)
                        .foregroundColor(AppColors.Widget.prayerTertiaryText)
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
                                    .foregroundColor(AppColors.Widget.prayerCheckmark)
                            }
                        }
                        .foregroundColor(AppColors.Widget.prayerPrimaryText)
                    }
                }
            }
            .padding()
        }
    }

}
