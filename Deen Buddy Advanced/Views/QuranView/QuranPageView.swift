//
//  QuranPageView.swift
//  Deen Buddy Advanced
//
//  Book-like page view for displaying Quran verses
//

import SwiftUI

struct QuranPageView: View {
    let surah: Surah
    let language: QuranLanguage

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Surah Header
                VStack(spacing: 8) {
                    Text(surah.name)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.black)

                    Text(surah.transliteration)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(.black.opacity(0.8))

                    Text(surah.translation)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(.black.opacity(0.6))

                    HStack {
                        Text("\(surah.typeCapitalized)")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.black.opacity(0.5))

                        Spacer()

                        Text("\(surah.total_verses) Verses")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Bismillah (except for Surah 9)
                if surah.id != 9 && surah.id != 1 {
                    Text("بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ")
                        .font(.system(size: 26, design: .serif))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                }

                // Verses
                VStack(spacing: 16) {
                    ForEach(surah.verses) { verse in
                        VerseView(verse: verse, surahId: surah.id, language: language)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(
            // Radial gradient - lighter overall with subtle transition
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.998, green: 0.99, blue: 0.98),
                    Color(red: 0.995, green: 0.985, blue: 0.96),
                    Color(red: 0.99, green: 0.98, blue: 0.94),
                    Color(red: 0.985, green: 0.97, blue: 0.90)
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
        )
    }
}

struct VerseView: View {
    let verse: Verse
    let surahId: Int
    let language: QuranLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number (no circle)
            Text("\(verse.id)")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.black.opacity(0.6))

            // Verse text
            VStack(alignment: .leading, spacing: 8) {
                if let translation = verse.translation, !translation.isEmpty {
                    Text(translation)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.black)
                        .lineSpacing(6)
                } else {
                    // Fallback to Arabic if no translation
                    Text(verse.text)
                        .font(.system(size: 24, design: .serif))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineSpacing(10)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    QuranPageView(
        surah: Surah(
            id: 1,
            name: "الفاتحة",
            transliteration: "Al-Fatihah",
            translation: "The Opener",
            type: "meccan",
            total_verses: 7,
            verses: [
                Verse(id: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ", translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful")
            ]
        ),
        language: .english
    )
}
