//
//  DailyVerseViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for Daily Quran Verse feature
//

import Foundation
import Combine

class DailyVerseViewModel: ObservableObject {
    // Published properties that the View will observe
    @Published var verse: Verse?
    @Published var surahName: String = ""
    @Published var reference: String = ""
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    private let quranService = QuranService.shared
    private let languageManager = LanguageManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Listen for language changes
        languageManager.$selectedLanguage
            .sink { [weak self] _ in
                self?.loadDailyVerse()
            }
            .store(in: &cancellables)

        // Initial load
        loadDailyVerse()
    }

    // Load the daily verse based on current language
    func loadDailyVerse() {
        isLoading = true
        errorMessage = nil

        // Load in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Load Quran data
            let surahs = self.quranService.loadQuran()

            guard !surahs.isEmpty else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = AppStrings.today.couldNotLoadQuranData
                }
                return
            }

            // Get daily verse (filtered to 4-20 words for optimal display)
            guard let (verse, surah) = self.quranService.getDailyVerseFiltered(surahs: surahs, minWords: 4, maxWords: 20) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = AppStrings.today.couldNotSelectDailyVerse
                }
                return
            }

            // Update UI on main thread
            DispatchQueue.main.async {
                self.verse = verse
                self.surahName = surah.transliteration
                self.reference = "\(surah.transliteration) \(surah.id):\(verse.id)"
                self.isLoading = false
            }
        }
    }

    // Refresh to get a new verse (optional feature)
    func refresh() {
        loadDailyVerse()
    }

    // Check if translation is available
    var hasTranslation: Bool {
        return verse?.translation != nil
    }

    // Get display text based on language settings
    var displayText: String {
        guard let verse = verse else { return "" }

        // For Arabic-only file, show Arabic text
        if languageManager.selectedLanguage == .arabic {
            return verse.text
        }

        // For other languages, show translation if available
        return verse.translation ?? verse.text
    }

    // Always show Arabic text
    var arabicText: String {
        return verse?.text ?? ""
    }

    // Show translation if available
    var translationText: String? {
        return verse?.translation
    }
}
