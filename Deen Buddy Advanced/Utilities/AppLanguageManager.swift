//
//  AppLanguageManager.swift
//  Deen Buddy Advanced
//
//  Manages app-wide language settings
//  Separate from QuranLanguage which is for Quran translations only
//

import Foundation
import Combine

// App UI languages
enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case turkish = "tr"
    // Future languages ready to uncomment:
    // case arabic = "ar"
    // case urdu = "ur"
    // case french = "fr"
    // case spanish = "es"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        // case .arabic: return "العربية"
        // case .urdu: return "اردو"
        // case .french: return "Français"
        // case .spanish: return "Español"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        // case .arabic: return "🇸🇦"
        // case .urdu: return "🇵🇰"
        // case .french: return "🇫🇷"
        // case .spanish: return "🇪🇸"
        }
    }

    var isRTL: Bool {
        // Right-to-left languages
        switch self {
        case .english, .turkish: return false
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
            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = AppLanguage(rawValue: deviceLang) ?? .english
        }
    }

    // Load localized string from .strings file based on current language
    func getString(_ key: String, table: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle if language bundle not found
            return NSLocalizedString(key, tableName: table, bundle: .main, comment: "")
        }
        return NSLocalizedString(key, tableName: table, bundle: bundle, comment: "")
    }
}

// Notification for language changes
extension Notification.Name {
    static let appLanguageChanged = Notification.Name("appLanguageChanged")
}
