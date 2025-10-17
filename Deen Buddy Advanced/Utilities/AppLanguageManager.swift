//
//  AppLanguageManager.swift
//  Deen Buddy Advanced
//
//  Manages app-wide language settings
//  Separate from QuranLanguage which is for Quran translations only
//

import Foundation
import Combine

// App UI languages (currently only English, ready for more)
enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    // Future languages ready to uncomment:
    // case arabic = "ar"
    // case urdu = "ur"
    // case turkish = "tr"
    // case french = "fr"
    // case spanish = "es"

    var displayName: String {
        switch self {
        case .english: return "English"
        // case .arabic: return "العربية"
        // case .urdu: return "اردو"
        // case .turkish: return "Türkçe"
        // case .french: return "Français"
        // case .spanish: return "Español"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        // case .arabic: return "🇸🇦"
        // case .urdu: return "🇵🇰"
        // case .turkish: return "🇹🇷"
        // case .french: return "🇫🇷"
        // case .spanish: return "🇪🇸"
        }
    }

    var isRTL: Bool {
        // Right-to-left languages
        switch self {
        case .english: return false
        // case .arabic, .urdu: return true
        // default: return false
        }
    }
}

// Manages app-wide language preference
class AppLanguageManager: ObservableObject {
    static let shared = AppLanguageManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            // Trigger app refresh when language changes
            NotificationCenter.default.post(name: .appLanguageChanged, object: nil)
        }
    }

    private init() {
        // Load saved language or default to English
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            currentLanguage = lang
        } else {
            // Try to detect device language
            let deviceLang = Locale.current.languageCode ?? "en"
            currentLanguage = AppLanguage(rawValue: deviceLang) ?? .english
        }
    }

    // This function will be used later for actual translations
    // For now, it just returns the key
    func getString(for key: String) -> String {
        // Future: look up translation based on currentLanguage
        // For now, just return the English string
        return key
    }
}

// Notification for language changes
extension Notification.Name {
    static let appLanguageChanged = Notification.Name("appLanguageChanged")
}
