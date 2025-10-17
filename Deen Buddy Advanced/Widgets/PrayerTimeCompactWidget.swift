//
//  PrayerTimeCompactWidget.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct PrayerTimeCompactWidget: View {
    let nextPrayer = "Asr"
    let nextPrayerTime = "3:45 PM"

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: getPrayerIcon())
                .font(.system(size: 18))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(nextPrayer)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(nextPrayerTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    func getPrayerIcon() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "sunrise.fill"
        case 12..<15:
            return "sun.max.fill"
        case 15..<18:
            return "sun.min.fill"
        case 18..<20:
            return "sunset.fill"
        default:
            return "moon.stars.fill"
        }
    }
}

#Preview {
    PrayerTimeCompactWidget()
}
