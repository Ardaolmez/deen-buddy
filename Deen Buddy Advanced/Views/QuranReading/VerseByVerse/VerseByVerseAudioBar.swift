//
//  VerseByVerseAudioBar.swift
//  Deen Buddy Advanced
//
//  Audio bar for verse-by-verse reading view
//  Matches the clean reading view aesthetic
//

import SwiftUI

struct VerseByVerseAudioBar: View {
    @ObservedObject var audioPlayer: DailyVerseAudioPlayer
    let onSettingsTap: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Top row: Phase indicator and close button
            HStack {
                // Current phase pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(phaseColor)
                        .frame(width: 8, height: 8)

                    Text(audioPlayer.phaseLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )

                Spacer()

                // Settings button
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.VerseByVerse.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(.systemGray6)))
                }

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
