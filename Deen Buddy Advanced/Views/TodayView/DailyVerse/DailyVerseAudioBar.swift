//
//  DailyVerseAudioBar.swift
//  Deen Buddy Advanced
//
//  Compact audio bar for daily verse playback within the card
//

import SwiftUI

struct DailyVerseAudioBar: View {
    @ObservedObject var audioPlayer: DailyVerseAudioPlayer
    let onSettingsTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * audioPlayer.progress, height: 4)
                }
            }
            .frame(height: 4)

            // Controls row
            HStack(spacing: 12) {
                // Time elapsed
                Text(audioPlayer.currentTimeFormatted)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 36, alignment: .leading)

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
                            .fill(Color.white)
                            .frame(width: 40, height: 40)

                        if audioPlayer.playbackState == .loading {
                            ProgressView()
                                .tint(.black)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: audioPlayer.playbackState.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .offset(x: audioPlayer.playbackState.isPlaying ? 0 : 1) // Visual centering for play icon
                        }
                    }
                }

                Spacer()

                // Phase indicator + Settings
                HStack(spacing: 6) {
                    // Current phase indicator (only for Arabic+Translation mode)
                    if audioPlayer.playbackState.isPlaying || audioPlayer.playbackState.isPaused {
                        Text(audioPlayer.phaseLabel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.25))
                            )
                    }

                    // Settings button
                    Button(action: onSettingsTap) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 28, height: 28)
                    }
                }
                .frame(width: 80, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                )
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        DailyVerseAudioBar(
            audioPlayer: DailyVerseAudioPlayer(),
            onSettingsTap: {}
        )
        .padding()
    }
}
