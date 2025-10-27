//
//  QuranAudioService.swift
//  Deen Buddy Advanced
//
//  Service for managing Quran audio playback
//

import Foundation
import AVFoundation
import Combine

@MainActor
class QuranAudioService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentPlaybackInfo: AudioPlaybackInfo?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var selectedLanguage: AudioLanguage = .arabic
    @Published var arabicReciter: AudioReciter = AudioReciter.defaultArabic
    @Published var englishReciter: AudioReciter = AudioReciter.defaultEnglish

    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    // MARK: - Singleton
    static let shared = QuranAudioService()

    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback Control
    func play(surahId: Int, verseId: Int) {
        let reciter = selectedLanguage == .english ? englishReciter : arabicReciter
        let playbackInfo = AudioPlaybackInfo(
            surahId: surahId,
            verseId: verseId,
            reciter: reciter,
            language: selectedLanguage
        )

        // If same verse is already loaded, just resume
        if currentPlaybackInfo == playbackInfo, let player = audioPlayer, playbackState == .paused {
            player.play()
            playbackState = .playing
            startTimer()
            return
        }

        // Load and play new audio
        currentPlaybackInfo = playbackInfo
        playbackState = .loading

        loadAudio(for: playbackInfo)
    }

    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        playbackState = .paused
        stopTimer()
    }

    func resume() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        player.play()
        playbackState = .playing
        startTimer()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        playbackState = .stopped
        currentPlaybackInfo = nil
        currentTime = 0
        duration = 0
        stopTimer()
    }

    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        currentTime = time
    }

    // MARK: - Audio Loading
    private func loadAudio(for playbackInfo: AudioPlaybackInfo) {
        let audioPath = playbackInfo.audioFilePath()

        // Try to load from bundle first
        if let bundleURL = Bundle.main.url(forResource: audioPath, withExtension: nil) {
            loadAudioFile(from: bundleURL)
        } else {
            // For now, if file doesn't exist, show error
            playbackState = .error("Audio file not found")
            print("Audio file not found at path: \(audioPath)")
        }
    }

    private func loadAudioFile(from url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()

            self.audioPlayer = player
            self.duration = player.duration
            self.currentTime = 0

            player.play()
            playbackState = .playing
            startTimer()

        } catch {
            playbackState = .error("Failed to load audio: \(error.localizedDescription)")
            print("Failed to load audio from \(url): \(error)")
        }
    }

    // MARK: - Timer Management
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let player = self.audioPlayer else { return }
                self.currentTime = player.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Playback Control
    func playNext() {
        guard let current = currentPlaybackInfo else { return }
        // For now, just move to next verse (can be enhanced later with surah boundaries)
        play(surahId: current.surahId, verseId: current.verseId + 1)
    }

    func playPrevious() {
        guard let current = currentPlaybackInfo else { return }
        guard current.verseId > 1 else { return }
        play(surahId: current.surahId, verseId: current.verseId - 1)
    }

    // MARK: - Settings
    func setLanguage(_ language: AudioLanguage) {
        selectedLanguage = language
    }

    func setArabicReciter(_ reciter: AudioReciter) {
        arabicReciter = reciter
    }

    func setEnglishReciter(_ reciter: AudioReciter) {
        englishReciter = reciter
    }
}

// MARK: - AVAudioPlayerDelegate
extension QuranAudioService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if flag {
                // Auto-play next verse
                playNext()
            } else {
                playbackState = .stopped
            }
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            playbackState = .error(error?.localizedDescription ?? "Unknown error")
        }
    }
}
