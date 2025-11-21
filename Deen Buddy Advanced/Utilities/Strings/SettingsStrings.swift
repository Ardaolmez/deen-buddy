//
//  SettingsStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Settings
//

import Foundation

private let table = "Settings"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct SettingsStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var language: String { lang.getString("language", table: table) }
    static var notifications: String { lang.getString("notifications", table: table) }
    static var about: String { lang.getString("about", table: table) }
    static var moreLanguagesComingSoon: String { lang.getString("moreLanguagesComingSoon", table: table) }

    // Quran Translation Section
    static var quranTranslation: String { lang.getString("quranTranslation", table: table) }
    static var selected: String { lang.getString("selected", table: table) }

    // About Section
    static var appVersion: String { lang.getString("appVersion", table: table) }
    static let version = "1.0.0" // Not localized - version number

    // App Language Section
    static var appLanguage: String { lang.getString("appLanguage", table: table) }
    static var selectLanguage: String { lang.getString("selectLanguage", table: table) }
}
