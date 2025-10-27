//
//  AudioPlayerView.swift
//  Deen Buddy Advanced
//
//  Floating audio player for Quran recitation
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var audioService: QuranAudioService
    let surah: Surah

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 3)

                    // Progress
                    Rectangle()
                        .fill(Color.green)
                        .frame(
                            width: geometry.size.width * CGFloat(audioService.currentTime / max(audioService.duration, 1)),
                            height: 3
                        )
                }
            }
            .frame(height: 3)

            // Player controls
            HStack(spacing: 16) {
                // Current verse info
                VStack(alignment: .leading, spacing: 4) {
                    if let playbackInfo = audioService.currentPlaybackInfo {
                        Text("Verse \(playbackInfo.verseId)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(audioService.selectedLanguage.displayName)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        Text("No audio playing")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Control buttons
                HStack(spacing: 24) {
                    // Previous button
                    Button(action: {
                        audioService.playPrevious()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    .disabled(audioService.currentPlaybackInfo?.verseId ?? 0 <= 1)

                    // Play/Pause button
                    Button(action: {
                        togglePlayback()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 44, height: 44)

                            Image(systemName: playPauseIcon)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(audioService.playbackState == .loading)

                    // Next button
                    Button(action: {
                        audioService.playNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    .disabled(audioService.currentPlaybackInfo?.verseId ?? 0 >= surah.total_verses)
                }

                Spacer()

                // Time display
                Text(formatTime(audioService.currentTime))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 45)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }

    // MARK: - Helper Functions
    private var playPauseIcon: String {
        switch audioService.playbackState {
        case .playing:
            return "pause.fill"
        case .paused, .stopped:
            return "play.fill"
        case .loading:
            return "hourglass"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    private func togglePlayback() {
        switch audioService.playbackState {
        case .playing:
            audioService.pause()
        case .paused:
            audioService.resume()
        case .stopped, .error:
            // Start playing from first verse if stopped
            if let current = audioService.currentPlaybackInfo {
                audioService.play(surahId: current.surahId, verseId: current.verseId)
            } else {
                audioService.play(surahId: surah.id, verseId: 1)
            }
        case .loading:
            break
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Compact Audio Player Mini View
struct CompactAudioPlayerView: View {
    @ObservedObject var audioService: QuranAudioService

    var body: some View {
        HStack(spacing: 12) {
            // Play/Pause button
            Button(action: {
                if audioService.playbackState == .playing {
                    audioService.pause()
                } else {
                    audioService.resume()
                }
            }) {
                Image(systemName: audioService.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                if let playbackInfo = audioService.currentPlaybackInfo {
                    Text("Verse \(playbackInfo.verseId)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(formatTime(audioService.currentTime))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Close button
            Button(action: {
                audioService.stop()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color(.systemGray6)
                .cornerRadius(12)
        )
        .padding(.horizontal, 16)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
