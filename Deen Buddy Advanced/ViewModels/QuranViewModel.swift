//
//  QuranViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for Quran reading interface
//

import Foundation
import Combine

class QuranViewModel: ObservableObject {
    // Published properties
    @Published var surahs: [Surah] = []
    @Published var currentSurahIndex: Int = 0
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var showSettings: Bool = false
    @Published var showSurahSelector: Bool = false

    private let quranService = QuranService.shared
    private let languageManager = LanguageManager.shared
    private var cancellables = Set<AnyCancellable>()

    // Current Surah
    var currentSurah: Surah? {
        guard surahs.indices.contains(currentSurahIndex) else { return nil }
        return surahs[currentSurahIndex]
    }

    // Selected language
    var selectedLanguage: QuranLanguage {
        return languageManager.selectedLanguage
    }

    init() {
        // Listen for language changes
        languageManager.$selectedLanguage
            .sink { [weak self] _ in
                self?.loadQuran()
            }
            .store(in: &cancellables)

        // Initial load
        loadQuran()
    }

    func loadQuran() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let loadedSurahs = self.quranService.loadQuran()

            DispatchQueue.main.async {
                if loadedSurahs.isEmpty {
                    self.errorMessage = AppStrings.quran.couldNotLoadQuranData
                } else {
                    self.surahs = loadedSurahs
                }
                self.isLoading = false
            }
        }
    }

    // Navigation methods
    func goToNextSurah() {
        if currentSurahIndex < surahs.count - 1 {
            currentSurahIndex += 1
        }
    }

    func goToPreviousSurah() {
        if currentSurahIndex > 0 {
            currentSurahIndex -= 1
        }
    }

    func goToSurah(index: Int) {
        if surahs.indices.contains(index) {
            currentSurahIndex = index
        }
    }

    func goToSurahById(id: Int) {
        if let index = surahs.firstIndex(where: { $0.id == id }) {
            currentSurahIndex = index
        }
    }

    // Check if navigation is possible
    var canGoNext: Bool {
        return currentSurahIndex < surahs.count - 1
    }

    var canGoPrevious: Bool {
        return currentSurahIndex > 0
    }
}
