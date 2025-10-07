//
//  DailyVerseCard.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyVerseCard: View {
    let verse = "And He found you lost and guided you."
    let reference = "Surah Ad-Duha 93:7"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Quran Verse for You")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(verse)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Text(reference)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DailyVerseCard()
}
