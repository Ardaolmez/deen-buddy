//
//  QuranAudioBar.swift
//  Deen Buddy Advanced
//
//  Floating audio player bar for Quran verse-by-verse recitation
//

import SwiftUI

struct QuranAudioBar: View {
    @ObservedObject var audioPlayer: QuranAudioPlayer
    @State private var showReciterSheet = false
    @State private var availableReciters: [Reciter] = []
    @State private var isLoadingReciters = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        HStack(spacing: 16) {
            // Play/Pause Button
            Button(action: {
                if audioPlayer.playbackState.isPlaying {
                    audioPlayer.pause()
                } else {
                    audioPlayer.play()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.brown)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    if audioPlayer.playbackState == .loading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: playPauseIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(audioPlayer.currentVerse == nil)

            // Verse Info & Progress
            VStack(alignment: .leading, spacing: 4) {
                // Top row: Verse info and reciter selector
                HStack {
                    Text(verseTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.brown)

                    Spacer()

                    Button(action: {
                        loadRecitersAndShowSheet()
                    }) {
                        HStack(spacing: 4) {
                            if isLoadingReciters {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.brown)
                            } else {
                                Text(reciterName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.brown.opacity(0.7))

                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.brown.opacity(0.7))
                            }
                        }
                    }
                    .disabled(isLoadingReciters)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.brown.opacity(0.2))
                            .frame(height: 4)

                        // Progress
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.brown)
                            .frame(width: geometry.size.width * audioPlayer.progress, height: 4)
                    }
                }
                .frame(height: 4)

                // Time labels
                HStack {
                    Text(audioPlayer.currentTimeFormatted)
                        .font(.system(size: 11))
                        .foregroundColor(.brown.opacity(0.6))

                    Spacer()

                    Text(audioPlayer.durationFormatted)
                        .font(.system(size: 11))
                        .foregroundColor(.brown.opacity(0.6))
                }
            }

            // Navigation Buttons
            HStack(spacing: 12) {
                // Previous
                Button(action: {
                    Task {
                        await audioPlayer.playPreviousVerse()
                    }
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(audioPlayer.hasPreviousVerse ? .brown : .brown.opacity(0.3))
                }
                .disabled(!audioPlayer.hasPreviousVerse)

                // Next
                Button(action: {
                    Task {
                        await audioPlayer.playNextVerse()
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(audioPlayer.hasNextVerse ? .brown : .brown.opacity(0.3))
                }
                .disabled(!audioPlayer.hasNextVerse)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .sheet(isPresented: $showReciterSheet) {
            ReciterSelectionSheet(
                reciters: availableReciters,
                selectedReciterID: QuranAudioService.shared.selectedReciterID,
                onSelect: { reciter in
                    QuranAudioService.shared.selectedReciterID = reciter.id
                    audioPlayer.selectedReciter = reciter
                    showReciterSheet = false

                    // Reload audio with new reciter
                    if let surahID = audioPlayer.currentVerse?.surahNumber {
                        Task {
                            await audioPlayer.loadSurah(surahID, startingAtVerse: audioPlayer.currentVerseIndex)
                        }
                    }
                }
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
            Button("Retry") {
                loadRecitersAndShowSheet()
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Computed Properties
    private var playPauseIcon: String {
        audioPlayer.playbackState.isPlaying ? "pause.fill" : "play.fill"
    }

    private var verseTitle: String {
        if let verse = audioPlayer.currentVerse {
            return "Verse \(verse.verseNumber)"
        }
        return "Select a verse"
    }

    private var reciterName: String {
        if let reciter = audioPlayer.selectedReciter {
            return reciter.displayName
        }
        return "Select Reciter"
    }

    // MARK: - Methods
    private func loadRecitersAndShowSheet() {
        guard !isLoadingReciters else { return }

        isLoadingReciters = true
        Task {
            do {
                let reciters = try await QuranAudioService.shared.fetchReciters()
                await MainActor.run {
                    availableReciters = reciters
                    isLoadingReciters = false
                    if reciters.isEmpty {
                        errorMessage = "No reciters available. Please check your internet connection."
                        showError = true
                    } else {
                        showReciterSheet = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingReciters = false
                    errorMessage = "Failed to load reciters: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Reciter Selection Sheet
struct ReciterSelectionSheet: View {
    let reciters: [Reciter]
    let selectedReciterID: Int
    let onSelect: (Reciter) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(reciters) { reciter in
                    Button(action: {
                        onSelect(reciter)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reciter.displayName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                if let style = reciter.style, !style.isEmpty {
                                    Text(style)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if reciter.id == selectedReciterID {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Reciter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        QuranAudioBar(audioPlayer: QuranAudioPlayer())
    }
    .background(AppColors.Quran.backgroundGradientStart)
}
