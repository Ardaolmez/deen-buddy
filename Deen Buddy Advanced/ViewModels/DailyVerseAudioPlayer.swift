//
//  DailyVerseAudioPlayer.swift
//  Deen Buddy Advanced
//
//  Audio player for daily verse with support for Arabic, Translation, or Both
//  - Arabic: Quran.com API (uses selected reciter)
//  - English: AlQuran.cloud API (Ibrahim Walk - Sahih International)
//  - Turkish: iOS Text-to-Speech (AVSpeechSynthesizer)
//

import Foundation
import AVFoundation
import Combine

@MainActor
class DailyVerseAudioPlayer: NSObject, ObservableObject {
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

    // Text-to-Speech for Turkish
    private var speechSynthesizer: AVSpeechSynthesizer?
    private var translationText: String?

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
    override init() {
        super.init()
        setupAudioSession()
        preference = savedPreference
        observePlaybackEnd()
        setupSpeechSynthesizer()
    }

    private func setupSpeechSynthesizer() {
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer?.delegate = self
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
    func loadVerse(surah: Int, verse: Int, preference: DailyVerseAudioPreference, translationText: String? = nil) async {
        self.surahNumber = surah
        self.verseNumber = verse
        self.preference = preference
        self.translationText = translationText
        self.currentPhase = preference == .translationOnly ? .translation : .arabic

        playbackState = .loading
        progress = 0
        currentTime = 0
        duration = 0

        // If Turkish language, always fetch Arabic (translation disabled)
        let isTurkish = AppLanguageManager.shared.currentLanguage == .turkish

        // Fetch Arabic audio URL from Quran.com API (if needed or if Turkish)
        if preference != .translationOnly || isTurkish {
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
            // Resume TTS if it was paused
            if speechSynthesizer?.isPaused == true {
                speechSynthesizer?.continueSpeaking()
                playbackState = .playing
                return
            }
            player?.play()
            playbackState = .playing
            return
        }

        // If Turkish language, force Arabic only (Turkish TTS disabled for now)
        if AppLanguageManager.shared.currentLanguage == .turkish {
            playArabic()
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
        speechSynthesizer?.pauseSpeaking(at: .immediate)
        playbackState = .paused
    }

    func stop() {
        player?.pause()
        player = nil
        speechSynthesizer?.stopSpeaking(at: .immediate)
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
        currentPhase = .translation

        // Use Turkish TTS if app language is Turkish, otherwise English audio
        if AppLanguageManager.shared.currentLanguage == .turkish {
            playTurkishTTS()
        } else {
            let urlString = EnglishAudioConfig.audioURL(surah: surahNumber, verse: verseNumber)
            guard let url = URL(string: urlString) else {
                playbackState = .error("Translation audio not available")
                return
            }
            playURL(url)
        }
    }

    private func playTurkishTTS() {
        guard let text = translationText, !text.isEmpty else {
            playbackState = .error("Turkish translation not available")
            return
        }

        // Stop any existing speech
        speechSynthesizer?.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)

        // Try to get the best available Turkish male voice (Cem)
        // Priority: Premium > Enhanced > Compact > Default
        // Users can download enhanced voices in: Settings > Accessibility > Spoken Content > Voices > Turkish
        let voice = getTurkishMaleVoice()
        utterance.voice = voice

        // Fine-tune the voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85  // Slower for Quran recitation
        utterance.pitchMultiplier = 0.95  // Slightly lower pitch for male voice
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        playbackState = .playing
        speechSynthesizer?.speak(utterance)
    }

    private func getTurkishMaleVoice() -> AVSpeechSynthesisVoice? {
        // Get all available Turkish voices
        let turkishVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("tr")
        }

        // Debug: Print all available Turkish voices
        print("=== Available Turkish Voices ===")
        for voice in turkishVoices {
            print("Name: \(voice.name), ID: \(voice.identifier), Quality: \(voice.quality.rawValue)")
        }
        print("================================")

        // Sort by quality (higher is better) and prefer male voice (Cem)
        let sortedVoices = turkishVoices.sorted { $0.quality.rawValue > $1.quality.rawValue }

        // First try to find Cem (male) with best quality
        if let maleVoice = sortedVoices.first(where: { $0.name.lowercased().contains("cem") }) {
            print("Selected male Turkish voice: \(maleVoice.name) - \(maleVoice.identifier)")
            return maleVoice
        }

        // If no Cem, look for any male-sounding voice or highest quality
        if let bestVoice = sortedVoices.first {
            print("Selected Turkish voice: \(bestVoice.name) - \(bestVoice.identifier)")
            return bestVoice
        }

        // Last resort: default Turkish
        print("Using default Turkish voice")
        return AVSpeechSynthesisVoice(language: "tr-TR")
    }

    private func playURL(_ url: URL) {
        // Fully clean up previous player to prevent audio mixing
        removeTimeObserver()
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        // Create fresh player with AVURLAsset for better streaming control
        let asset = AVURLAsset(url: url, options: [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ])
        let playerItem = AVPlayerItem(asset: asset)

        // Create new player
        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = false

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
            .sink { [weak self] notification in
                Task { @MainActor in
                    // IMPORTANT: Only handle if this notification is for OUR current player item
                    guard let self = self,
                          let finishedItem = notification.object as? AVPlayerItem,
                          let currentItem = self.player?.currentItem,
                          finishedItem === currentItem else {
                        return
                    }
                    self.handlePlaybackEnded()
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
        case .arabic: return CommonStrings.arabic
        case .translation: return CommonStrings.translation
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension DailyVerseAudioPlayer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.handleTTSFinished()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            // TTS was cancelled, do nothing special
        }
    }

    @MainActor
    private func handleTTSFinished() {
        // If Arabic+Translation mode and Arabic just finished, this won't be called
        // because Arabic uses AVPlayer, not TTS
        // This is only called when Turkish TTS finishes
        if preference == .arabicThenTranslation && currentPhase == .translation {
            // Translation finished after Arabic
            stop()
        } else if preference == .translationOnly {
            // Translation only mode finished
            stop()
        }
    }
}
