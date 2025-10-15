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
    case urdu = "ur"
    case turkish = "tr"
    case indonesian = "id"
    case french = "fr"
    case spanish = "es"
    case russian = "ru"
    case chinese = "zh"
    case bengali = "bn"
    case swedish = "sv"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية (Arabic)"
        case .urdu: return "اردو (Urdu)"
        case .turkish: return "Türkçe (Turkish)"
        case .indonesian: return "Bahasa Indonesia"
        case .french: return "Français (French)"
        case .spanish: return "Español (Spanish)"
        case .russian: return "Русский (Russian)"
        case .chinese: return "中文 (Chinese)"
        case .bengali: return "বাংলা (Bengali)"
        case .swedish: return "Svenska (Swedish)"
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
