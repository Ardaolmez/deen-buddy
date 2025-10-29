//
//  ReadingPageContentView.swift
//  Deen Buddy Advanced
//
//  Single page view for displaying Quran verses (English only)
//

import SwiftUI

struct ReadingPageContentView: View {
    let page: QuranReadingPage
    @ObservedObject private var fontSizeManager = QuranFontSizeManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Surah header if this is the first verse of a new surah
                if let firstVerse = page.verses.first, firstVerse.verseNumber == 1 {
                    surahHeader(for: firstVerse)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                }

                // Verses
                ForEach(page.verses) { verseContext in
                    verseRow(verseContext)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Surah Header

    private func surahHeader(for verseContext: VerseWithContext) -> some View {
        VStack(spacing: 12) {
            // Surah name
            Text(verseContext.surahTransliteration)
                .font(.system(size: fontSizeManager.scaledFontSize(24), weight: .bold, design: .serif))
                .foregroundColor(AppColors.Reading.surahName)

            // Decorative divider
            HStack(spacing: 12) {
                Rectangle()
                    .fill(AppColors.Reading.surahDivider)
                    .frame(width: 60, height: 2)

                Image(systemName: "star.fill")
                    .font(.system(size: fontSizeManager.scaledFontSize(10)))
                    .foregroundColor(AppColors.Reading.surahDivider)

                Rectangle()
                    .fill(AppColors.Reading.surahDivider)
                    .frame(width: 60, height: 2)
            }
        }
    }

    // MARK: - Verse Row

    private func verseRow(_ verseContext: VerseWithContext) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Verse number circle
                ZStack {
                    Circle()
                        .fill(AppColors.Reading.progressBackground)
                        .frame(width: 36, height: 36)

                    Circle()
                        .stroke(AppColors.Reading.verseNumber.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 36, height: 36)

                    Text("\(verseContext.verseNumber)")
                        .font(.system(size: fontSizeManager.scaledFontSize(14), weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.Reading.verseNumber)
                }

                // English translation
                if let translation = verseContext.verse.translation {
                    Text(translation)
                        .font(.system(size: fontSizeManager.scaledFontSize(18), weight: .regular, design: .serif))
                        .foregroundColor(AppColors.Reading.verseText)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 12)

            // Divider between verses
            if verseContext.id != page.verses.last?.id {
                Divider()
                    .background(AppColors.Reading.verseDivider)
            }
        }
    }
}

#Preview {
    let sampleVerse1 = Verse(
        id: 1,
        text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful."
    )

    let sampleVerse2 = Verse(
        id: 2,
        text: "ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ",
        translation: "All praise is due to Allah, Lord of the worlds."
    )

    let sampleSurah = Surah(
        id: 1,
        name: "الفاتحة",
        transliteration: "Al-Fatihah",
        translation: "The Opener",
        type: "meccan",
        total_verses: 7,
        verses: [sampleVerse1, sampleVerse2]
    )

    let page = QuranReadingPage(
        id: 0,
        verses: [
            VerseWithContext(verse: sampleVerse1, surah: sampleSurah, absolutePosition: 0),
            VerseWithContext(verse: sampleVerse2, surah: sampleSurah, absolutePosition: 1)
        ]
    )

    return ReadingPageContentView(page: page)
        .padding()
}
