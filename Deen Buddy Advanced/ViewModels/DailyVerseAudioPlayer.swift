//
//  DailyVerseAudioPlayer.swift
//  Deen Buddy Advanced
//
//  Audio player for daily verse with support for Arabic, Translation, or Both
//  - Arabic: Quran.com API (uses selected reciter)
//  - English: AlQuran.cloud API (Ibrahim Walk - Sahih International)
//

import Foundation
import AVFoundation
import Combine

@MainActor
class DailyVerseAudioPlayer: ObservableObject {
    // MARK: - Published Properties
    @Published var playbackState: PlaybackState = .idle
    @Published var progress: Double = 0.0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentPhase: AudioPhase = .arabic  // Which part is playing

    // MARK: - Audio Phase
    enum AudioPhase: Equatable {
        case arabic
        case translation
    }

    // MARK: - Private Properties
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    // Verse info
    private var surahNumber: Int = 1
    private var verseNumber: Int = 1
    private var preference: DailyVerseAudioPreference = .arabicOnly

    // Arabic audio URL (from Quran.com API)
    private var arabicAudioURL: String?

    // MARK: - Preference Storage
    private let preferenceKey = "dailyVerseAudioPreference"
    private let hasSetPreferenceKey = "hasSetDailyVerseAudioPreference"

    var hasSetPreference: Bool {
        UserDefaults.standard.bool(forKey: hasSetPreferenceKey)
    }

    var savedPreference: DailyVerseAudioPreference {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: preferenceKey),
                  let pref = DailyVerseAudioPreference(rawValue: rawValue) else {
                return .arabicOnly
            }
            return pref
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: preferenceKey)
            UserDefaults.standard.set(true, forKey: hasSetPreferenceKey)
            preference = newValue
        }
    }

    // MARK: - Initialization
    init() {
        setupAudioSession()
        preference = savedPreference
        observePlaybackEnd()
    }

    deinit {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        cancellables.removeAll()
    }

    // MARK: - Audio Session
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
            try audioSession.setActive(true)
        } catch {
            print("DailyVerseAudioPlayer: Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Load Verse
    func loadVerse(surah: Int, verse: Int, preference: DailyVerseAudioPreference) async {
        self.surahNumber = surah
        self.verseNumber = verse
        self.preference = preference
        self.currentPhase = preference == .translationOnly ? .translation : .arabic

        playbackState = .loading
        progress = 0
        currentTime = 0
        duration = 0

        // Fetch Arabic audio URL from Quran.com API (if needed)
        if preference != .translationOnly {
            await fetchArabicAudioURL()
        }

        playbackState = .idle
    }

    private func fetchArabicAudioURL() async {
        do {
            let audioService = QuranAudioService.shared
            let verses = try await audioService.fetchVersesAudio(surahID: surahNumber)

            if let audioVerse = verses.first(where: { $0.verseNumber == verseNumber }) {
                arabicAudioURL = audioVerse.audio.fullURL
            } else {
                print("DailyVerseAudioPlayer: Verse \(verseNumber) not found in surah \(surahNumber)")
            }
        } catch {
            print("DailyVerseAudioPlayer: Failed to fetch Arabic audio: \(error)")
        }
    }

    // MARK: - Playback Controls
    func play() {
        if playbackState.isPaused {
            player?.play()
            playbackState = .playing
            return
        }

        // Start fresh playback based on preference
        switch preference {
        case .arabicOnly:
            playArabic()
        case .translationOnly:
            playTranslation()
        case .arabicThenTranslation:
            currentPhase = .arabic
            playArabic()
        }
    }

    func pause() {
        player?.pause()
        playbackState = .paused
    }

    func stop() {
        player?.pause()
        player = nil
        removeTimeObserver()
        playbackState = .idle
        progress = 0
        currentTime = 0
        duration = 0
        currentPhase = preference == .translationOnly ? .translation : .arabic
    }

    // MARK: - Play Specific Audio
    private func playArabic() {
        guard let urlString = arabicAudioURL,
              let url = URL(string: urlString) else {
            // If Arabic URL not available, try translation
            if preference == .arabicThenTranslation {
                currentPhase = .translation
                playTranslation()
            } else {
                playbackState = .error("Arabic audio not available")
            }
            return
        }

        currentPhase = .arabic
        playURL(url)
    }

    private func playTranslation() {
        let urlString = EnglishAudioConfig.audioURL(surah: surahNumber, verse: verseNumber)
        guard let url = URL(string: urlString) else {
            playbackState = .error("Translation audio not available")
            return
        }

        currentPhase = .translation
        playURL(url)
    }

    private func playURL(_ url: URL) {
        removeTimeObserver()
        player?.pause()

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        addTimeObserver()

        player?.play()
        playbackState = .playing
    }

    // MARK: - Time Observer
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
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

    // MARK: - Playback End Observer
    private func observePlaybackEnd() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handlePlaybackEnded()
                }
            }
            .store(in: &cancellables)
    }

    private func handlePlaybackEnded() {
        // If Arabic+Translation mode and Arabic just finished, play translation
        if preference == .arabicThenTranslation && currentPhase == .arabic {
            // Small delay between Arabic and Translation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.playTranslation()
            }
        } else {
            // Playback complete
            stop()
        }
    }

    // MARK: - Helpers
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }

    var durationFormatted: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var phaseLabel: String {
        switch currentPhase {
        case .arabic: return "Arabic"
        case .translation: return "Translation"
        }
    }
}
