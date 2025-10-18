//
//  CircularPrayerWidget.swift
//  Lock Screen Circular Widget
//

import SwiftUI
import WidgetKit

struct CircularPrayerWidget: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: entry.prayerIcon)
                    .font(.system(size: 20))

                Text(entry.prayerTime, style: .time)
                    .font(.system(size: 11).bold())
            }
        }
    }
}
