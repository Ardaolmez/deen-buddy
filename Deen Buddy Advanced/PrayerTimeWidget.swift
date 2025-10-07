//
//  PrayerTimeWidget.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct PrayerTimeWidget: View {
    let nextPrayer = "Asr"
    let nextPrayerTime = "3:45 PM"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: getPrayerIcon())
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(nextPrayer)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(nextPrayerTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
    PrayerTimeWidget()
}
