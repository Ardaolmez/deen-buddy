//
//  LargeVerseWidget.swift
//  Deen Buddy Widgets
//
//  Large verse widget view
//

import SwiftUI
import WidgetKit

struct LargeVerseWidget: View {
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

            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.title)
                    Text(WidgetStrings.quranVerse)
                        .font(.headline)
                    Spacer()
                }
                .foregroundColor(AppColors.Widget.versePrimaryText)

                Divider()
                    .background(AppColors.Widget.verseDivider)

                Spacer()

                // Verse text (centered and prominent)
                VStack(spacing: 12) {
                    Text(entry.verseText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .lineLimit(8)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.Widget.versePrimaryText)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal)

                    Text(entry.verseReference)
                        .font(.callout)
                        .foregroundColor(AppColors.Widget.verseSecondaryText)
                }

                Spacer()

                // Decorative bottom element
                HStack {
                    Spacer()
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundColor(AppColors.Widget.verseTertiaryText)
                    Spacer()
                }
            }
            .padding()
        }
    }
}
