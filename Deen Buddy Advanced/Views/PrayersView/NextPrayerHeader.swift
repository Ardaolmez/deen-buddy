// Views/PrayersView/NextPrayerHeader.swift
import SwiftUI

struct NextPrayerHeader: View {
    let nextPrayer: PrayerEntry?
    let currentPrayer: PrayerEntry?
    let countdown: String
    let isBetweenSunriseAndDhuhr: Bool

    var body: some View {
        VStack(spacing: MinimalDesign.mediumSpacing) {
            // Show current prayer if available, otherwise next prayer
            if let prayer = nextPrayer ?? currentPrayer {
                VStack(spacing: MinimalDesign.smallSpacing + 4) {
                    // Prayer icon with subtle background
                    ZStack {
                        Circle()
                            .fill(AppColors.Prayers.subtleBlue)
                            .frame(width: MinimalDesign.largeCircle, height: MinimalDesign.largeCircle)

                        Image(systemName: prayer.name.icon)
                            .font(.system(size: MinimalDesign.largeIcon, weight: .light))
                            .foregroundStyle( AppColors.Prayers.prayerBlue )
                    }

                    // Prayer name
                    Text(prayer.name.title)
                        .font(.system(.title2, weight: .light))
                        .foregroundStyle(AppColors.Common.primary)

                    // Status and countdown in one line
                    HStack(spacing: MinimalDesign.smallSpacing) {
                       
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(AppColors.Prayers.prayerGreen)
                                    .frame(width: 6, height: 6)
                                Text(AppStrings.prayers.nextPrayer)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.Prayers.prayerGreen)
                            }
                        
                        if !countdown.isEmpty && countdown != "—" && countdown != "--:--:--" {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(AppColors.Common.secondary)

                            Text(countdown)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(AppColors.Common.secondary)
                        }
                    }
                }
            } else {
                VStack(spacing: MinimalDesign.smallSpacing + 4) {
                    ZStack {
                        Circle()
                            .fill(AppColors.Prayers.subtleGreen)
                            .frame(width: MinimalDesign.largeCircle, height: MinimalDesign.largeCircle)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: MinimalDesign.largeIcon, weight: .light))
                            .foregroundStyle(AppColors.Prayers.prayerGreen)
                    }

                    Text(AppStrings.prayers.allComplete)
                        .font(.system(.title3, weight: .light))
                        .foregroundStyle(AppColors.Prayers.prayerGreen)

                    Text(AppStrings.prayers.greatJob)
                        .font(.caption)
                        .foregroundStyle(AppColors.Common.secondary)
                }
            }
        }
        .padding(.vertical, MinimalDesign.largeSpacing)
    }
}
