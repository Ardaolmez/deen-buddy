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
                        colors: [Color(red: 0.2, green: 0.4, blue: 0.3), Color(red: 0.15, green: 0.35, blue: 0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                // Book icon
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))

                // Verse text
                Text(entry.verseText)
                    .font(.caption)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)

                // Surah reference
                Text(entry.verseReference)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
    }
}
