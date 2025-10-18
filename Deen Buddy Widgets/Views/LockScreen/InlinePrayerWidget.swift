//
//  InlinePrayerWidget.swift
//  Lock Screen Inline Widget
//

import SwiftUI
import WidgetKit

struct InlinePrayerWidget: View {
    let entry: PrayerEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.prayerIcon)
            Text(entry.prayerName)
            Text(entry.prayerTime, style: .time)
        }
        .font(.caption)
    }
}
