//
//  ReadingStrings.swift
//  Deen Buddy Advanced
//
//  Enhanced string definitions for Quran Reading feature with metrics and progress
//

import Foundation

private let table = "Reading"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct ReadingStrings {
    // MARK: - Header & Navigation
    static var goal: String { lang.getString("goal", table: table) }
    static var timeFormat: String { lang.getString("timeFormat", table: table) }
    static var close: String { lang.getString("close", table: table) }
    static var currentPosition: String { lang.getString("currentPosition", table: table) }

    // MARK: - Verse Display
    static var verse: String { lang.getString("verse", table: table) }
    static var surahHeader: String { lang.getString("surahHeader", table: table) }
    static var versesRemaining: String { lang.getString("versesRemaining", table: table) }
    static var minutesRemaining: String { lang.getString("minutesRemaining", table: table) }

    // MARK: - Progress & Completion
    static var progress: String { lang.getString("progress", table: table) }
    static var completed: String { lang.getString("completed", table: table) }
    static var keepGoing: String { lang.getString("keepGoing", table: table) }
    static var overallProgress: String { lang.getString("overallProgress", table: table) }
    static var dailyGoal: String { lang.getString("dailyGoal", table: table) }
    static var goalCompleted: String { lang.getString("goalCompleted", table: table) }

    // MARK: - Session Management
    static var readingSession: String { lang.getString("readingSession", table: table) }
    static var sessionEnded: String { lang.getString("sessionEnded", table: table) }
    static var sessionActive: String { lang.getString("sessionActive", table: table) }
    static var totalTimeToday: String { lang.getString("totalTimeToday", table: table) }
    static var sessionInsights: String { lang.getString("sessionInsights", table: table) }

    // MARK: - Metrics & Analytics
    static var readingSpeed: String { lang.getString("readingSpeed", table: table) }
    static var versesPerMinute: String { lang.getString("versesPerMinute", table: table) }
    static var estimatedCompletion: String { lang.getString("estimatedCompletion", table: table) }
    static var readingEfficiency: String { lang.getString("readingEfficiency", table: table) }
    static var focusScore: String { lang.getString("focusScore", table: table) }
    static var consistencyScore: String { lang.getString("consistencyScore", table: table) }

    // MARK: - Progress Ring Labels
    static var goalProgress: String { lang.getString("goalProgress", table: table) }
    static var versesReadToday: String { lang.getString("versesReadToday", table: table) }
    static var readingTimeToday: String { lang.getString("readingTimeToday", table: table) }
    static var streakCounter: String { lang.getString("streakCounter", table: table) }
    static var bestStreak: String { lang.getString("bestStreak", table: table) }

    // MARK: - Achievement & Motivation
    static var currentStreak: String { lang.getString("currentStreak", table: table) }
    static var achievement: String { lang.getString("achievement", table: table) }
    static var weekWarrior: String { lang.getString("weekWarrior", table: table) }
    static var monthlyMaster: String { lang.getString("monthlyMaster", table: table) }
    static var centuryScholar: String { lang.getString("centuryScholar", table: table) }
    static var streakProtection: String { lang.getString("streakProtection", table: table) }
    static var almostThere: String { lang.getString("almostThere", table: table) }
    static var keepItUp: String { lang.getString("keepItUp", table: table) }

    // MARK: - Goal Types
    static var oneWeekGoal: String { lang.getString("oneWeekGoal", table: table) }
    static var twoWeekGoal: String { lang.getString("twoWeekGoal", table: table) }
    static var oneMonthGoal: String { lang.getString("oneMonthGoal", table: table) }
    static var threeMonthGoal: String { lang.getString("threeMonthGoal", table: table) }
    static var microLearningGoal: String { lang.getString("microLearningGoal", table: table) }
    static var versesGoal: String { lang.getString("versesGoal", table: table) }
    static var timeGoal: String { lang.getString("timeGoal", table: table) }

    // MARK: - Status Indicators
    static var onTrack: String { lang.getString("onTrack", table: table) }
    static var ahead: String { lang.getString("ahead", table: table) }
    static var behind: String { lang.getString("behind", table: table) }
    static var excellent: String { lang.getString("excellent", table: table) }
    static var good: String { lang.getString("good", table: table) }
    static var needsImprovement: String { lang.getString("needsImprovement", table: table) }

    // MARK: - Reading Experience
    static var pageOf: String { lang.getString("pageOf", table: table) }
    static var surahProgress: String { lang.getString("surahProgress", table: table) }
    static var verseHighlight: String { lang.getString("verseHighlight", table: table) }
    static var readingFocus: String { lang.getString("readingFocus", table: table) }
    static var nightMode: String { lang.getString("nightMode", table: table) }
    static var fontSizeAdjust: String { lang.getString("fontSizeAdjust", table: table) }

    // MARK: - Adaptive Messages
    static var morningMotivation: String { lang.getString("morningMotivation", table: table) }
    static var afternoonEncouragement: String { lang.getString("afternoonEncouragement", table: table) }
    static var eveningReminder: String { lang.getString("eveningReminder", table: table) }
    static var streakReminder: String { lang.getString("streakReminder", table: table) }
    static var comebackMessage: String { lang.getString("comebackMessage", table: table) }

    // MARK: - Error & Loading States
    static var loadingQuran: String { lang.getString("loadingQuran", table: table) }
    static var errorLoadingData: String { lang.getString("errorLoadingData", table: table) }
    static var retryLoading: String { lang.getString("retryLoading", table: table) }
    static var noGoalSet: String { lang.getString("noGoalSet", table: table) }
    static var setGoalPrompt: String { lang.getString("setGoalPrompt", table: table) }

    // MARK: - Verse Navigation
    static var selectSurah: String { lang.getString("selectSurah", table: table) }
    static var selectVerse: String { lang.getString("selectVerse", table: table) }
    static var selectJuz: String { lang.getString("selectJuz", table: table) }
    static var searchSurah: String { lang.getString("searchSurah", table: table) }
    static var searchVerse: String { lang.getString("searchVerse", table: table) }
    static var searchJuz: String { lang.getString("searchJuz", table: table) }
    static var back: String { lang.getString("back", table: table) }
    static var cancel: String { lang.getString("cancel", table: table) }
    static var verses: String { lang.getString("verses", table: table) }
    static var verseCount: String { lang.getString("verseCount", table: table) }
    static var noResults: String { lang.getString("noResults", table: table) }
    static var searchPlaceholder: String { lang.getString("searchPlaceholder", table: table) }
    static var juzFormat: String { lang.getString("juzFormat", table: table) }
    static var surahsRange: String { lang.getString("surahsRange", table: table) }
    static var surah: String { lang.getString("surah", table: table) }
    static var juz: String { lang.getString("juz", table: table) }
}
