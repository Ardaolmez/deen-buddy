//
//  MediumVerseWidget.swift
//  Deen Buddy Widgets
//
//  Medium verse widget view
//

import SwiftUI
import WidgetKit

struct MediumVerseWidget: View {
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

            HStack(spacing: 12) {
                // Book icon
                VStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.Widget.verseSecondaryText)
                }

                Divider()
                    .background(AppColors.Widget.verseDivider)

                // Verse content
                VStack(alignment: .leading, spacing: 8) {
                    Text(WidgetStrings.quranVerse)
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.verseTertiaryText)

                    Text(entry.verseText)
                        .font(.callout)
                        .lineLimit(5)
                        .foregroundColor(AppColors.Widget.versePrimaryText)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text(entry.verseReference)
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.verseSecondaryText)
                }

                Spacer()
            }
            .padding()
        }
    }
}
