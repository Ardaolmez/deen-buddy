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
                        colors: [Color(red: 0.2, green: 0.4, blue: 0.3), Color(red: 0.15, green: 0.35, blue: 0.25)],
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
                .foregroundColor(.white)

                Divider()
                    .background(.white.opacity(0.3))

                Spacer()

                // Verse text (centered and prominent)
                VStack(spacing: 12) {
                    Text(entry.verseText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .lineLimit(8)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal)

                    Text(entry.verseReference)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Decorative bottom element
                HStack {
                    Spacer()
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }
            }
            .padding()
        }
    }
}
