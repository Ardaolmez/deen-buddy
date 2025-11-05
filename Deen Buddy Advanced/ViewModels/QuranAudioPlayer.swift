//
//  QuranAudioPlayer.swift
//  Deen Buddy Advanced
//
//  Audio player manager for verse-by-verse Quran recitation
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

@MainActor
class QuranAudioPlayer: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var playbackState: PlaybackState = .idle
    @Published var currentVerse: AudioVerse?
    @Published var currentVerseIndex: Int = 0
    @Published var progress: Double = 0.0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var selectedReciter: Reciter?
    @Published var currentSurahID: Int?

    // MARK: - Private Properties
    private var player: AVPlayer?
    private var audioService = QuranAudioService.shared
    private var verses: [AudioVerse] = []
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    // Auto-advance setting
    var autoAdvanceEnabled: Bool = true

    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
        loadSelectedReciter()
    }

    deinit {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        cancellables.removeAll()
    }

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Lock Screen Controls
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task { @MainActor in
                self.play()
            }
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task { @MainActor in
                self.pause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task { @MainActor in
                await self.playNextVerse()
            }
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            Task { @MainActor in
                await self.playPreviousVerse()
            }
            return .success
        }
    }

    // MARK: - Load Content
    func loadSurah(_ surahID: Int, startingAtVerse: Int = 0) async {
        currentSurahID = surahID
        playbackState = .loading
        print("🎵 Loading surah \(surahID)...")

        do {
            verses = try await audioService.fetchVersesAudio(surahID: surahID)
            print("🎵 Loaded \(verses.count) verses for surah \(surahID)")

            guard !verses.isEmpty else {
                playbackState = .error("No verses found")
                return
            }

            currentVerseIndex = min(startingAtVerse, verses.count - 1)
            currentVerse = verses[currentVerseIndex]
            playbackState = .idle
            print("🎵 Ready to play from verse index \(currentVerseIndex)")

        } catch {
            print("🎵 Error loading surah: \(error.localizedDescription)")
            playbackState = .error(error.localizedDescription)
        }
    }

    private func loadSelectedReciter() {
        Task {
            selectedReciter = try? await audioService.getSelectedReciter()
        }
    }

    // MARK: - Playback Controls
    func play() {
        guard let currentVerse = currentVerse else { return }

        if let player = player, playbackState.isPaused {
            player.play()
            playbackState = .playing
            updateNowPlayingInfo()
            return
        }

        loadAndPlayVerse(currentVerse)
    }

    func pause() {
        player?.pause()
        playbackState = .paused
        updateNowPlayingInfo()
    }

    func stop() {
        player?.pause()
        player = nil
        removeTimeObserver()
        playbackState = .idle
        progress = 0
        currentTime = 0
        duration = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Verse Navigation
    func playNextVerse() async {
        print("🎵 playNextVerse called: currentIndex=\(currentVerseIndex), totalVerses=\(verses.count)")

        guard currentVerseIndex < verses.count - 1 else {
            print("🎵 End of surah reached. Moving to next surah...")
            // End of current surah - check if we can continue to next surah
            if let currentSurahID = currentSurahID, currentSurahID < 114 {
                // Load and play next surah
                await loadSurah(currentSurahID + 1, startingAtVerse: 0)
                if playbackState != .error("") {
                    loadAndPlayVerse(verses[0])
                }
            } else {
                // End of entire Quran (surah 114)
                stop()
            }
            return
        }

        currentVerseIndex += 1
        currentVerse = verses[currentVerseIndex]
        print("🎵 Playing next verse: index=\(currentVerseIndex), verseNumber=\(currentVerse?.verseNumber ?? 0)")
        loadAndPlayVerse(verses[currentVerseIndex])
    }

    func playPreviousVerse() async {
        guard currentVerseIndex > 0 else { return }

        currentVerseIndex -= 1
        currentVerse = verses[currentVerseIndex]
        loadAndPlayVerse(verses[currentVerseIndex])
    }

    func playVerse(at index: Int) {
        guard index >= 0 && index < verses.count else { return }

        currentVerseIndex = index
        currentVerse = verses[index]

        if playbackState.isPlaying {
            loadAndPlayVerse(verses[index])
        }
    }

    // MARK: - Private Methods
    private func loadAndPlayVerse(_ verse: AudioVerse) {
        guard let url = URL(string: verse.audio.fullURL) else {
            playbackState = .error("Invalid audio URL")
            return
        }

        removeTimeObserver()
        player?.pause()

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        addTimeObserver()
        observePlaybackEnd()

        player?.play()
        playbackState = .playing
        updateNowPlayingInfo()
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    private func updateProgress() {
        guard let player = player,
              let currentItem = player.currentItem else { return }

        let current = player.currentTime().seconds
        let total = currentItem.duration.seconds

        if total.isFinite && total > 0 {
            currentTime = current
            duration = total
            progress = current / total
        }
    }

    private func observePlaybackEnd() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self = self else { return }

                    if self.autoAdvanceEnabled {
                        await self.playNextVerse()
                    } else {
                        self.playbackState = .paused
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func updateNowPlayingInfo() {
        guard let verse = currentVerse,
              let reciter = selectedReciter else { return }

        var nowPlayingInfo = [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyTitle] = "Verse \(verse.verseNumber)"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "\(reciter.displayName) - Surah \(verse.surahNumber)"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Deen Buddy"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackState.isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Public Helpers
    var hasNextVerse: Bool {
        // Can go to next verse in current surah, or to next surah if available
        if currentVerseIndex < verses.count - 1 {
            return true
        }
        // At end of current surah - check if there's a next surah
        return currentSurahID != nil && currentSurahID! < 114
    }

    var hasPreviousVerse: Bool {
        currentVerseIndex > 0
    }

    var totalVerses: Int {
        verses.count
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var currentTimeFormatted: String {
        formattedTime(currentTime)
    }

    var durationFormatted: String {
        formattedTime(duration)
    }
}
