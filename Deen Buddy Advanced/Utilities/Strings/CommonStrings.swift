//
//  CommonStrings.swift
//  Deen Buddy Advanced
//
//  Common strings used throughout the app
//

import Foundation

private let table = "Common"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct CommonStrings {
    // Tab Labels
    static var todayTab: String { lang.getString("todayTab", table: table) }
    static var quranTab: String { lang.getString("quranTab", table: table) }
    static var prayersTab: String { lang.getString("prayersTab", table: table) }
    static var exploreTab: String { lang.getString("exploreTab", table: table) }

    // Actions
    static var close: String { lang.getString("close", table: table) }
    static var done: String { lang.getString("done", table: table) }
    static var cancel: String { lang.getString("cancel", table: table) }
    static var retry: String { lang.getString("retry", table: table) }
    static var share: String { lang.getString("share", table: table) }
    static var yes: String { lang.getString("yes", table: table) }
    static var no: String { lang.getString("no", table: table) }
    static var ok: String { lang.getString("ok", table: table) }
    static var save: String { lang.getString("save", table: table) }
    static var delete: String { lang.getString("delete", table: table) }
    static var edit: String { lang.getString("edit", table: table) }
    static var continueAction: String { lang.getString("continueAction", table: table) }

    // States
    static var loading: String { lang.getString("loading", table: table) }
    static var error: String { lang.getString("error", table: table) }
    static var success: String { lang.getString("success", table: table) }

    // Daily Streak
    static var dailyStreak: String { lang.getString("dailyStreak", table: table) }
    // Day abbreviations - localized
    static var daysOfWeek: [String] {
        switch lang.currentLanguage {
        case .turkish:
            return ["P", "P", "S", "Ç", "P", "C", "C"]
        default:
            return ["S", "M", "T", "W", "T", "F", "S"]
        }
    }

    // Personalized Learning
    static var personalizedLearning: String { lang.getString("personalizedLearning", table: table) }
    static var prophetsStories: String { lang.getString("prophetsStories", table: table) }
    static var lessonProgress: String { lang.getString("lessonProgress", table: table) }
    static var start: String { lang.getString("start", table: table) }

    // Text Labels
    static var arabic: String { lang.getString("arabic", table: table) }
    static var translation: String { lang.getString("translation", table: table) }
}
