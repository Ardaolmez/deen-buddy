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

    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    @State private var showBookmarkPopup = false

    // Audio state - lazy loaded to avoid slow initialization on every page
    @State private var audioPlayer: DailyVerseAudioPlayer?
    @State private var showAudioBar = false
    @State private var showPreferenceSheet = false

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

                        // Verse number badge with favorite and bookmark buttons
                        verseActionsRow(verse: verse)

                        // Audio bar (shown when listening)
                        if showAudioBar, let player = audioPlayer {
                            VerseByVerseAudioBar(
                                audioPlayer: player,
                                onSettingsTap: {
                                    showPreferenceSheet = true
                                },
                                onClose: {
                                    player.stop()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAudioBar = false
                                    }
                                }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

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
        .sheet(isPresented: $showBookmarkPopup) {
            if let verse = verseContext {
                AddToBookmarkPopup(
                    surahId: getSurahIdFromContext(verse),
                    verseId: verse.verseNumber
                )
            }
        }
        .sheet(isPresented: $showPreferenceSheet) {
            AudioPreferenceSheet(
                currentPreference: audioPlayer?.hasSetPreference == true ? audioPlayer?.savedPreference : nil,
                onSelect: { preference in
                    // Create player if needed
                    if audioPlayer == nil {
                        audioPlayer = DailyVerseAudioPlayer()
                    }
                    audioPlayer?.savedPreference = preference
                    if let verse = verseContext {
                        loadAndPlayAudio(verse: verse, preference: preference)
                    }
                }
            )
        }
        .onChange(of: page.id) { _ in
            // Stop audio when page changes
            if showAudioBar {
                audioPlayer?.stop()
                showAudioBar = false
            }
        }
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

    // MARK: - Verse Actions Row (Number + Favorite + Bookmark)

    private func verseActionsRow(verse: VerseWithContext) -> some View {
        let surahId = getSurahIdFromContext(verse)
        let verseId = verse.verseNumber
        let isFavorited = favoritesManager.isFavorite(surahId: surahId, verseId: verseId)
        let isBookmarked = bookmarksManager.isVerseBookmarked(surahId: surahId, verseId: verseId)

        return HStack(spacing: 16) {
            // Favorite button
            Button(action: {
                favoritesManager.toggleFavorite(surahId: surahId, verseId: verseId)
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isFavorited ? AppColors.Prayers.prayerGreen.opacity(0.1) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFavorited ? AppColors.Prayers.prayerGreen : Color(.systemGray4), lineWidth: 2)
                        )
                        .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 4, x: 0, y: 2)

                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isFavorited ? AppColors.Prayers.prayerGreen : AppColors.VerseByVerse.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Verse number badge (tap for audio)
            verseNumberBadge(number: verse.verseNumber, verse: verse)

            // Bookmark button
            Button(action: {
                showBookmarkPopup = true
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isBookmarked ? AppColors.Prayers.prayerGreen.opacity(0.1) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isBookmarked ? AppColors.Prayers.prayerGreen : Color(.systemGray4), lineWidth: 2)
                        )
                        .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 4, x: 0, y: 2)

                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isBookmarked ? AppColors.Prayers.prayerGreen : AppColors.VerseByVerse.textSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func verseNumberBadge(number: Int, verse: VerseWithContext) -> some View {
        Button(action: {
            handleAudioTap(verse: verse)
        }) {
            ZStack {
                // Background with border - changes when audio is playing
                RoundedRectangle(cornerRadius: 12)
                    .fill(showAudioBar ? AppColors.Prayers.prayerGreen.opacity(0.15) : AppColors.VerseByVerse.verseNumberBackground)
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(showAudioBar ? AppColors.Prayers.prayerGreen : AppColors.VerseByVerse.verseNumberBorder, lineWidth: 2)
                    )
                    .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 4)
                    .shadow(color: showAudioBar ? AppColors.Prayers.prayerGreen.opacity(0.3) : AppColors.VerseByVerse.glowGold, radius: 12, x: 0, y: 0)

                // Verse number or audio icon
                if showAudioBar && audioPlayer?.playbackState.isPlaying == true {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                } else if showAudioBar {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                } else {
                    Text("\(number)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.VerseByVerse.verseNumberText)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Audio Helpers

    private func handleAudioTap(verse: VerseWithContext) {
        if showAudioBar, let player = audioPlayer {
            // Toggle play/pause if audio bar is already shown
            if player.playbackState.isPlaying {
                player.pause()
            } else if player.playbackState.isPaused {
                player.play()
            } else {
                // Stopped - close the bar
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAudioBar = false
                }
            }
        } else {
            // Create player lazily if needed
            if audioPlayer == nil {
                audioPlayer = DailyVerseAudioPlayer()
            }

            // Open audio bar
            if audioPlayer?.hasSetPreference != true {
                showPreferenceSheet = true
            } else if let preference = audioPlayer?.savedPreference {
                loadAndPlayAudio(verse: verse, preference: preference)
            }
        }

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    private func loadAndPlayAudio(verse: VerseWithContext, preference: DailyVerseAudioPreference) {
        let surahId = getSurahIdFromContext(verse)
        let verseId = verse.verseNumber

        // Create player if needed
        if audioPlayer == nil {
            audioPlayer = DailyVerseAudioPlayer()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            showAudioBar = true
        }

        Task {
            await audioPlayer?.loadVerse(surah: surahId, verse: verseId, preference: preference)
            audioPlayer?.play()
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
