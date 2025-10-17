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
        HStack(spacing: 6) {
            Image(systemName: prayerIcon)
                .font(.system(size: 18))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(prayerName)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(prayerTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
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
            return "--:--"
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
