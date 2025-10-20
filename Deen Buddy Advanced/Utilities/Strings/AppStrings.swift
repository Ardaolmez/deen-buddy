//
//  AppStrings.swift
//  Deen Buddy Advanced
//
//  Main entry point for all app strings
//  Usage: AppStrings.today.navigationTitle, AppStrings.common.close
//

import Foundation

struct AppStrings {
    // App Identity
    static let appName = "Murshid"
    static let appTagline = "Your religious guide"

    // Tabs
    static let today = TodayStrings.self
    static let prayers = PrayersStrings.self
    static let quiz = QuizStrings.self
    static let quran = QuranStrings.self
    static let explore = ExploreStrings.self
    static let chat = ChatStrings.self

    // Shared
    static let common = CommonStrings.self
    static let settings = SettingsStrings.self
}
