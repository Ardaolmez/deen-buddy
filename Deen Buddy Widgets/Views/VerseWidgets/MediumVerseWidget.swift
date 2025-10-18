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
                        colors: [Color(red: 0.2, green: 0.4, blue: 0.3), Color(red: 0.15, green: 0.35, blue: 0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 12) {
                // Book icon
                VStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.9))
                }

                Divider()
                    .background(.white.opacity(0.3))

                // Verse content
                VStack(alignment: .leading, spacing: 8) {
                    Text(WidgetStrings.quranVerse)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    Text(entry.verseText)
                        .font(.callout)
                        .lineLimit(5)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text(entry.verseReference)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding()
        }
    }
}
