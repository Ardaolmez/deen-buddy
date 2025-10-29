//
//  EnhancedReadingPageContentView.swift
//  Deen Buddy Advanced
//
//  Enhanced reading page with adaptive sizing, animations, and improved UX
//

import SwiftUI

struct EnhancedReadingPageContentView: View {
    let page: QuranReadingPage
    let isCurrentPage: Bool
    let pageConfiguration: ScreenDimensionManager.PageConfiguration
    
    @ObservedObject private var fontSizeManager = QuranFontSizeManager.shared
    @State private var highlightedVerseIndex: Int? = nil
    @State private var showVerseNumbers: Bool = true
    @State private var animateContent: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Simple surah header only for new surahs
                if let firstVerse = page.verses.first, firstVerse.verseNumber == 1 {
                    simpleSurahHeader(for: firstVerse)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                }

                // Verses with clean styling
                LazyVStack(spacing: 12) {
                    ForEach(Array(page.verses.enumerated()), id: \.element.id) { index, verseContext in
                        cleanVerseRow(verseContext, index: index)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, pageConfiguration.horizontalPadding)
            .padding(.vertical, 16)
        }
        .background(AppColors.Reading.pageCenter)
    }
    
    // MARK: - Simple Surah Header

    private func simpleSurahHeader(for verseContext: VerseWithContext) -> some View {
        VStack(spacing: 12) {
            // Surah name in English and transliteration
            VStack(spacing: 4) {
                Text(getSurahEnglishName(for: getSurahIdFromContext(verseContext)))
                    .font(.system(size: pageConfiguration.fontSize + 2, weight: .semibold))
                    .foregroundColor(AppColors.Reading.surahName)

                Text(verseContext.surahTransliteration)
                    .font(.system(size: pageConfiguration.fontSize, weight: .medium))
                    .foregroundColor(AppColors.Reading.surahTransliteration)
            }

            // Bismillah for all surahs except At-Tawbah (Surah 9)
            if getSurahIdFromContext(verseContext) != 9 {
                Text("بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ")
                    .font(.system(size: pageConfiguration.fontSize + 4, weight: .medium))
                    .foregroundColor(AppColors.Reading.darkBackgroundMid)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Page Progress Indicator
    
    private var pageProgressIndicator: some View {
        HStack {
            Text("Page \(page.id + 1)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.Reading.metricsSecondary)
            
            Spacer()
            
            Text("Verses \(page.firstVersePosition + 1) - \(page.lastVersePosition + 1)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.Reading.metricsSecondary)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Clean Verse Row

    private func cleanVerseRow(_ verseContext: VerseWithContext, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Simple verse number
            Text("\(verseContext.verseNumber)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.Reading.verseNumber)
                .frame(minWidth: 24)

            // Verse translation only
            Text(verseContext.verse.translation!)
                .font(.system(size: pageConfiguration.fontSize, weight: .regular, design: .serif))
                .foregroundColor(AppColors.Reading.verseText)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
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
        // Extract surah ID from the verse context ID which is in format "surahId-verseId"
        let components = verseContext.id.components(separatedBy: "-")
        if let surahIdString = components.first, let surahId = Int(surahIdString) {
            return surahId
        }
        return 1 // Default to Al-Fatihah if parsing fails
    }

}

// MARK: - Preview

#Preview {
    let sampleVerse1 = Verse(
        id: 1,
        text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful."
    )
    
    let sampleVerse2 = Verse(
        id: 2,
        text: "ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ",
        translation: "All praise is due to Allah, Lord of the worlds, the Entirely Merciful, the Especially Merciful, Sovereign of the Day of Recompense."
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
    
    let config = ScreenDimensionManager.PageConfiguration(
        versesPerPage: 8,
        fontSize: 16,
        verseSpacing: 16,
        horizontalPadding: 20,
        availableWidth: 350,
        availableHeight: 600
    )
    
    EnhancedReadingPageContentView(
        page: page,
        isCurrentPage: true,
        pageConfiguration: config
    )
    .background(AppColors.Reading.background)
}
