//
//  VerseByVerseContentView.swift
//  Deen Buddy Advanced
//
//  Fancy verse-by-verse reading view with Arabic and English centered
//

import SwiftUI

struct VerseByVerseContentView: View {
    let page: QuranReadingPage
    let isCurrentPage: Bool

    var verseContext: VerseWithContext? {
        page.verses.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Main content
                if let verse = verseContext {
                    VStack(spacing: 24) {
                        // Surah header (only for verse 1)
                        if verse.verseNumber == 1 {
                            surahHeader(for: verse)
                                .transition(.opacity.combined(with: .scale))
                                .padding(.top, 16)
                        } else {
                            Spacer()
                                .frame(height: 24)
                        }

                        // Arabic text - centered and prominent with card background
                        arabicTextView(verse: verse)

                        // Verse number badge
                        verseNumberBadge(number: verse.verseNumber)

                        // English translation - centered
                        translationTextView(verse: verse)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Surah Header

    private func surahHeader(for verseContext: VerseWithContext) -> some View {
        VStack(spacing: 16) {
            // Decorative top line
            HStack(spacing: 8) {
                decorativeLine()
                Circle()
                    .fill(AppColors.VerseByVerse.ornamentTop)
                    .frame(width: 6, height: 6)
                decorativeLine()
            }
            .padding(.horizontal, 40)

            // Surah name in English
            Text(getSurahEnglishName(for: getSurahIdFromContext(verseContext)))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(AppColors.VerseByVerse.surahName)
                .shadow(color: AppColors.VerseByVerse.glowGold, radius: 8, x: 0, y: 0)

            // Surah transliteration
            Text(verseContext.surahTransliteration)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.VerseByVerse.surahTransliteration)
                .tracking(1)
                .textCase(.uppercase)

            // Bismillah (except for Surah 9)
            if getSurahIdFromContext(verseContext) != 9 {
                Text("بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.VerseByVerse.bismillah)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .shadow(color: AppColors.VerseByVerse.glowGold, radius: 6, x: 0, y: 0)
            }

            // Decorative bottom line
            HStack(spacing: 8) {
                decorativeLine()
                Circle()
                    .fill(AppColors.VerseByVerse.ornamentBottom)
                    .frame(width: 6, height: 6)
                decorativeLine()
            }
            .padding(.horizontal, 40)
        }
    }

    private func decorativeLine() -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        AppColors.VerseByVerse.dividerLine,
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }

    // MARK: - Arabic Text

    private func arabicTextView(verse: VerseWithContext) -> some View {
        Text(verse.verse.text)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(AppColors.VerseByVerse.arabicText)
            .multilineTextAlignment(.center)
            .lineSpacing(16)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.VerseByVerse.arabicCardGradient)
                    .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 2)
            )
    }

    // MARK: - Verse Number Badge

    private func verseNumberBadge(number: Int) -> some View {
        ZStack {
            // Background with border
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.VerseByVerse.verseNumberBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.VerseByVerse.verseNumberBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 4)
                .shadow(color: AppColors.VerseByVerse.glowGold, radius: 12, x: 0, y: 0)

            // Verse number
            Text("\(number)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.VerseByVerse.verseNumberText)
        }
    }

    // MARK: - Translation Text

    private func translationTextView(verse: VerseWithContext) -> some View {
        VStack(spacing: 12) {
            // Translation text
            if let translation = verse.verse.translation {
                Text(translation)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(AppColors.VerseByVerse.translationText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.VerseByVerse.translationCardGradient)
                            .shadow(color: AppColors.VerseByVerse.shadowSecondary, radius: 8, x: 0, y: 4)
                    )
            }
        }
    }

    // MARK: - Helper Functions

    private func getSurahEnglishName(for surahId: Int) -> String {
        let surahNames = [
            1: "The Opening", 2: "The Cow", 3: "The Family of Imran", 4: "The Women",
            5: "The Table", 6: "The Cattle", 7: "The Heights", 8: "The Spoils of War",
            9: "The Repentance", 10: "Jonah", 11: "Hud", 12: "Joseph",
            13: "The Thunder", 14: "Abraham", 15: "The Rocky Tract", 16: "The Bees",
            17: "The Night Journey", 18: "The Cave", 19: "Mary", 20: "Ta-Ha",
            21: "The Prophets", 22: "The Pilgrimage", 23: "The Believers", 24: "The Light",
            25: "The Criterion", 26: "The Poets", 27: "The Ants", 28: "The Stories",
            29: "The Spider", 30: "The Romans", 31: "Luqman", 32: "The Prostration",
            33: "The Combined Forces", 34: "Sheba", 35: "The Originator", 36: "Ya-Sin",
            37: "Those Ranged in Ranks", 38: "Sad", 39: "The Groups", 40: "The Forgiver",
            41: "Distinguished", 42: "The Consultation", 43: "The Gold", 44: "The Smoke",
            45: "The Kneeling", 46: "The Valley", 47: "Muhammad", 48: "The Victory",
            49: "The Dwellings", 50: "Qaf", 51: "The Scatterers", 52: "The Mount",
            53: "The Star", 54: "The Moon", 55: "The Most Gracious", 56: "The Event",
            57: "The Iron", 58: "The Reasoning", 59: "The Gathering", 60: "The Tested",
            61: "The Ranks", 62: "Friday", 63: "The Hypocrites", 64: "The Loss & Gain",
            65: "The Divorce", 66: "The Prohibition", 67: "The Kingdom", 68: "The Pen",
            69: "The Inevitable", 70: "The Levels", 71: "Noah", 72: "The Jinn",
            73: "The Wrapped", 74: "The Covered", 75: "The Resurrection", 76: "The Human",
            77: "Those Sent", 78: "The Great News", 79: "Those Who Pull", 80: "He Frowned",
            81: "The Overthrowing", 82: "The Cleaving", 83: "The Defrauders", 84: "The Splitting",
            85: "The Stars", 86: "The Nightcomer", 87: "The Most High", 88: "The Overwhelming",
            89: "The Dawn", 90: "The City", 91: "The Sun", 92: "The Night",
            93: "The Forenoon", 94: "The Opening-Up", 95: "The Fig", 96: "The Clot",
            97: "The Night of Decree", 98: "The Clear Evidence", 99: "The Earthquake", 100: "The Runners",
            101: "The Striking Hour", 102: "The Piling Up", 103: "The Time", 104: "The Slanderer",
            105: "The Elephant", 106: "Quraish", 107: "The Small Kindnesses", 108: "The River in Paradise",
            109: "The Disbelievers", 110: "The Help", 111: "The Palm Fiber", 112: "The Sincerity",
            113: "The Daybreak", 114: "The People"
        ]
        return surahNames[surahId] ?? "Unknown"
    }

    private func getSurahIdFromContext(_ verseContext: VerseWithContext) -> Int {
        let components = verseContext.id.components(separatedBy: "-")
        if let surahIdString = components.first, let surahId = Int(surahIdString) {
            return surahId
        }
        return 1
    }
}

// MARK: - Preview

#Preview {
    let sampleVerse = Verse(
        id: 1,
        text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful."
    )

    let sampleSurah = Surah(
        id: 1,
        name: "الفاتحة",
        transliteration: "Al-Fatihah",
        translation: "The Opener",
        type: "meccan",
        total_verses: 7,
        verses: [sampleVerse]
    )

    let page = QuranReadingPage(
        id: 0,
        verses: [
            VerseWithContext(verse: sampleVerse, surah: sampleSurah, absolutePosition: 0)
        ]
    )

    VerseByVerseContentView(
        page: page,
        isCurrentPage: true
    )
}
