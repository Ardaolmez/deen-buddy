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

    @StateObject private var audioService = QuranAudioService.shared
    @State private var showAudioPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
            VStack(spacing: 20) {
                // Surah Header
                VStack(spacing: 12) {
                    // Arabic name with decorative elements
                    Text(surah.name)
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(AppColors.Quran.surahNameArabic)
                        .padding(.bottom, 4)

                    // Transliteration and translation
                    VStack(spacing: 8) {
                        Text(surah.transliteration)
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                            .foregroundColor(AppColors.Quran.surahNameTransliteration)

                        Text(surah.translation)
                            .font(.system(size: 20, weight: .regular, design: .serif))
                            .foregroundColor(AppColors.Quran.surahNameTranslation)
                    }

                    // Metadata with better spacing
                    HStack(spacing: 20) {
                        Text("\(surah.typeCapitalized)")
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .foregroundColor(AppColors.Quran.surahMetadata)

                        Text("•")
                            .foregroundColor(AppColors.Quran.surahMetadata.opacity(0.5))

                        Text(String(format: AppStrings.quran.versesCount, surah.total_verses))
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .foregroundColor(AppColors.Quran.surahMetadata)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 12)

                // Bismillah (except for Surah 9)
                if surah.id != 9 && surah.id != 1 {
                    VStack(spacing: 8) {
                        Text("بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ")
                            .font(.system(size: 30, weight: .medium, design: .serif))
                            .foregroundColor(AppColors.Quran.bismillah)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 16)

                        // Decorative divider after Bismillah
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(AppColors.Quran.verseNumber.opacity(0.2))
                                .frame(width: 60, height: 1)

                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.Quran.verseNumber.opacity(0.3))

                            Rectangle()
                                .fill(AppColors.Quran.verseNumber.opacity(0.2))
                                .frame(width: 60, height: 1)
                        }
                        .padding(.bottom, 12)
                    }
                }

                // Verses
                VStack(spacing: 0) {
                    ForEach(surah.verses) { verse in
                        VerseView(
                            verse: verse,
                            surahId: surah.id,
                            language: language,
                            audioService: audioService,
                            onPlayTapped: {
                                showAudioPlayer = true
                                audioService.play(surahId: surah.id, verseId: verse.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, showAudioPlayer ? 120 : 40)
            }
        }
        .background(
            // Radial gradient - lighter overall with subtle transition
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.Quran.pageCenter,
                    AppColors.Quran.pageRing1,
                    AppColors.Quran.pageRing2,
                    AppColors.Quran.pageRing3,
                    AppColors.Quran.pageRing4
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
        )

            // Audio player at bottom
            if showAudioPlayer {
                AudioPlayerView(audioService: audioService, surah: surah)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(), value: showAudioPlayer)
    }
}

struct VerseView: View {
    let verse: Verse
    let surahId: Int
    let language: QuranLanguage
    @ObservedObject var audioService: QuranAudioService
    let onPlayTapped: () -> Void

    private var isCurrentlyPlaying: Bool {
        guard let playbackInfo = audioService.currentPlaybackInfo else { return false }
        return playbackInfo.surahId == surahId && playbackInfo.verseId == verse.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Verse container with both Arabic and translation
            HStack(alignment: .top, spacing: 16) {
                // Verse number in decorative circle (tappable for audio)
                Button(action: onPlayTapped) {
                    ZStack {
                        Circle()
                            .fill(isCurrentlyPlaying ? Color.green.opacity(0.2) : Color(red: 0.95, green: 0.93, blue: 0.88))
                            .frame(width: 36, height: 36)

                        Circle()
                            .stroke(
                                isCurrentlyPlaying ? Color.green : AppColors.Quran.verseNumber.opacity(0.3),
                                lineWidth: isCurrentlyPlaying ? 2 : 1
                            )
                            .frame(width: 36, height: 36)

                        if isCurrentlyPlaying && audioService.playbackState == .playing {
                            Image(systemName: "waveform")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        } else {
                            Text("\(verse.id)")
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundColor(isCurrentlyPlaying ? .green : AppColors.Quran.verseNumber)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Verse content
                VStack(alignment: .leading, spacing: 12) {
                    // Always show Arabic text first
                    Text(verse.text)
                        .font(.system(size: 28, design: .serif))
                        .foregroundColor(AppColors.Quran.verseText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineSpacing(14)
                        .fixedSize(horizontal: false, vertical: true)

                    // Show translation if available and not Arabic language
                    if let translation = verse.translation,
                       !translation.isEmpty,
                       language != .arabic {
                        Text(translation)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundColor(AppColors.Quran.verseText.opacity(0.85))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Subtle divider between verses
            Divider()
                .background(AppColors.Quran.verseNumber.opacity(0.15))
                .padding(.top, 8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 4)
        .background(
            isCurrentlyPlaying ?
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.05))
                : nil
        )
        .animation(.easeInOut(duration: 0.3), value: isCurrentlyPlaying)
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
