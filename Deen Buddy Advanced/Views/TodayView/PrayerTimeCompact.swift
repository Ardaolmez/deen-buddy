//
//  PrayerTimeCompactWidget.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct PrayerTimeCompact: View {
    let nextPrayer: PrayerEntry?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: prayerIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.Today.prayerCompactIcon)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(AppColors.Today.prayerCompactIcon.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(prayerName)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.Common.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text(prayerTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Computed Properties

    private var prayerName: String {
        guard let prayer = nextPrayer else {
            return AppStrings.prayers.locating
        }
        return prayer.name.title
    }

    private var prayerTime: String {
        guard let prayer = nextPrayer else {
            return AppStrings.prayers.timePlaceholder
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: prayer.time)
    }

    private var prayerIcon: String {
        guard let prayer = nextPrayer else {
            return "moon.stars.fill"
        }

        switch prayer.name {
        case .fajr:
            return "sunrise.fill"
        case .dhuhr:
            return "sun.max.fill"
        case .asr:
            return "sun.min.fill"
        case .maghrib:
            return "sunset.fill"
        case .isha:
            return "moon.stars.fill"
        }
    }
}

#Preview {
    PrayerTimeCompact(nextPrayer: PrayerEntry(name: .asr, time: Date()))
}
