//
//  SmallVerseWidget.swift
//  Deen Buddy Widgets
//
//  Small verse widget view
//

import SwiftUI
import WidgetKit

struct SmallVerseWidget: View {
    let entry: VerseEntry

    var body: some View {
        ZStack {
            // Background gradient (Quran-inspired colors)
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [AppColors.Widget.verseBackgroundStart, AppColors.Widget.verseBackgroundEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                // Book icon
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.Widget.verseSecondaryText)

                // Verse text
                Text(entry.verseText)
                    .font(.caption)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.Widget.versePrimaryText)
                    .minimumScaleFactor(0.8)

                // Surah reference
                Text(entry.verseReference)
                    .font(.caption2)
                    .foregroundColor(AppColors.Widget.verseTertiaryText)
            }
            .padding()
        }
    }
}
