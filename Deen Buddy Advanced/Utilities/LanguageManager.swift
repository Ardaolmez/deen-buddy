//
//  LanguageManager.swift
//  Deen Buddy Advanced
//
//  Language management system for Quran translations
//

import Foundation
import Combine

// Supported languages for Quran translations
enum QuranLanguage: String, CaseIterable, Codable {
    case english = "en"
    case arabic = "ar"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية (Arabic)"
        }
    }

    var fileName: String {
        // Returns the JSON file name for this language
        if self == .arabic {
            return "quran" // Arabic only file has no language suffix
        }
        return "quran_\(rawValue)"
    }
}

// Singleton to manage app-wide language settings
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var selectedLanguage: QuranLanguage {
        didSet {
            saveLanguagePreference()
        }
    }

    private let userDefaultsKey = "selectedQuranLanguage"

    private init() {
        // Load saved language or default to English
        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey),
           let language = QuranLanguage(rawValue: savedLanguage) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = .english
        }
    }

    private func saveLanguagePreference() {
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: userDefaultsKey)
    }

    // Get the file name for the currently selected language
    func getQuranFileName() -> String {
        return selectedLanguage.fileName
    }

    // Check if translation is available for selected language
    func isTranslationAvailable() -> Bool {
        guard let url = Bundle.main.url(forResource: selectedLanguage.fileName, withExtension: "json") else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
