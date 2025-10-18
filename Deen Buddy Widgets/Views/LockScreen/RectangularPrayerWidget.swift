//
//  RectangularPrayerWidget.swift
//  Lock Screen Rectangular Widget
//

import SwiftUI
import WidgetKit

struct RectangularPrayerWidget: View {
    let entry: PrayerEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.prayerIcon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.prayerName)
                    .font(.headline)

                Text(entry.prayerTime, style: .time)
                    .font(.caption.bold())
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
