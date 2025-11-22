//
//  VerseByVerseAudioBar.swift
//  Deen Buddy Advanced
//
//  Audio bar for verse-by-verse reading view
//  With language/mode selector
//

import SwiftUI

struct VerseByVerseAudioBar: View {
    @ObservedObject var audioPlayer: DailyVerseAudioPlayer
    let onSettingsTap: () -> Void
    let onClose: () -> Void

    // Check if Turkish - only Arabic available
    private var isTurkish: Bool {
        AppLanguageManager.shared.currentLanguage == .turkish
    }

    var body: some View {
        VStack(spacing: 12) {
            // Top row: Language selector and close button
            HStack {
                // Language/Mode selector - tap to open settings sheet
                // Disabled when Turkish (only Arabic available)
                Button(action: onSettingsTap) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(phaseColor)
                            .frame(width: 8, height: 8)

                        Text(isTurkish ? CommonStrings.arabic : audioPlayer.savedPreference.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isTurkish ? AppColors.VerseByVerse.textSecondary : AppColors.VerseByVerse.textPrimary)

                        if !isTurkish {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.VerseByVerse.textSecondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
                }
                .disabled(isTurkish)

                Spacer()

                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.VerseByVerse.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(.systemGray6)))
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColors.Prayers.prayerGreen)
                        .frame(width: geometry.size.width * audioPlayer.progress, height: 6)
                }
            }
            .frame(height: 6)

            // Bottom row: Time and play/pause
            HStack {
                // Current time
                Text(audioPlayer.currentTimeFormatted)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.VerseByVerse.textSecondary)

                Spacer()

                // Play/Pause button
                Button(action: {
                    if audioPlayer.playbackState.isPlaying {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.Prayers.prayerGreen)
                            .frame(width: 44, height: 44)
                            .shadow(color: AppColors.Prayers.prayerGreen.opacity(0.3), radius: 8, x: 0, y: 4)

                        if audioPlayer.playbackState == .loading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: audioPlayer.playbackState.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: audioPlayer.playbackState.isPlaying ? 0 : 2)
                        }
                    }
                }

                Spacer()

                // Duration
                Text(audioPlayer.durationFormatted)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.VerseByVerse.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 4)
        )
    }

    private var phaseColor: Color {
        switch audioPlayer.currentPhase {
        case .arabic:
            return AppColors.Prayers.prayerGreen
        case .translation:
            return Color.blue
        }
    }
}

#Preview {
    VStack {
        VerseByVerseAudioBar(
            audioPlayer: DailyVerseAudioPlayer(),
            onSettingsTap: {},
            onClose: {}
        )
        .padding()
    }
    .background(Color(.systemBackground))
}
