//
//  ReadingStrings.swift
//  Deen Buddy Advanced
//
//  Enhanced string definitions for Quran Reading feature with metrics and progress
//

import Foundation

struct ReadingStrings {
    // MARK: - Header & Navigation
    static let goal = "Goal: 5 min"
    static let timeFormat = "%d:%02d"  // minutes:seconds
    static let close = "Close"
    static let currentPosition = "Current: %@"

    // MARK: - Verse Display
    static let verse = "Verse %d"
    static let surahHeader = "%@ - %@" // Name - Translation
    static let versesRemaining = "%d verses remaining"
    static let minutesRemaining = "%d minutes remaining"

    // MARK: - Progress & Completion
    static let progress = "Progress"
    static let completed = "Completed!"
    static let keepGoing = "Keep going!"
    static let overallProgress = "Overall Progress"
    static let dailyGoal = "Daily Goal"
    static let goalCompleted = "Goal Completed! 🎉"

    // MARK: - Session Management
    static let readingSession = "Reading Session"
    static let sessionEnded = "Session ended"
    static let sessionActive = "Session Active"
    static let totalTimeToday = "Total time today: %d min"
    static let sessionInsights = "Session Insights"

    // MARK: - Metrics & Analytics
    static let readingSpeed = "Reading Speed"
    static let versesPerMinute = "%.1f v/min"
    static let estimatedCompletion = "Est. Completion"
    static let readingEfficiency = "Efficiency"
    static let focusScore = "Focus Score"
    static let consistencyScore = "Consistency"

    // MARK: - Progress Ring Labels
    static let goalProgress = "Goal Progress"
    static let versesReadToday = "Verses Read Today"
    static let readingTimeToday = "Reading Time Today"
    static let streakCounter = "%d day streak"
    static let bestStreak = "Best: %d"

    // MARK: - Achievement & Motivation
    static let currentStreak = "Current Streak"
    static let achievement = "Achievement!"
    static let weekWarrior = "Week Warrior 🔥"
    static let monthlyMaster = "Monthly Master ⭐"
    static let centuryScholar = "Century Scholar 💎"
    static let streakProtection = "Streak Protection"
    static let almostThere = "Almost there!"
    static let keepItUp = "Keep it up!"

    // MARK: - Goal Types
    static let oneWeekGoal = "1 Week Goal"
    static let twoWeekGoal = "2 Week Goal"
    static let oneMonthGoal = "1 Month Goal"
    static let threeMonthGoal = "3 Month Goal"
    static let microLearningGoal = "5 Minutes Daily"
    static let versesGoal = "VERSES\nGOAL"
    static let timeGoal = "5 MIN\nDAILY"

    // MARK: - Status Indicators
    static let onTrack = "On Track"
    static let ahead = "Ahead"
    static let behind = "Behind"
    static let excellent = "Excellent"
    static let good = "Good"
    static let needsImprovement = "Needs Improvement"

    // MARK: - Reading Experience
    static let pageOf = "Page %d of %d"
    static let surahProgress = "Surah Progress"
    static let verseHighlight = "Current Verse"
    static let readingFocus = "Reading Focus"
    static let nightMode = "Night Mode"
    static let fontSizeAdjust = "Font Size"

    // MARK: - Adaptive Messages
    static let morningMotivation = "Start your day with Quran ☀️"
    static let afternoonEncouragement = "Perfect time for reflection 🌅"
    static let eveningReminder = "End your day peacefully 🌙"
    static let streakReminder = "Don't break your %d-day streak!"
    static let comebackMessage = "Welcome back! Let's continue your journey"

    // MARK: - Error & Loading States
    static let loadingQuran = "Loading Quran..."
    static let errorLoadingData = "Error loading data"
    static let retryLoading = "Retry"
    static let noGoalSet = "No reading goal set"
    static let setGoalPrompt = "Set a reading goal to get started"

    // MARK: - Verse Navigation
    static let selectSurah = "Select Surah"
    static let selectVerse = "Select Verse"
    static let searchSurah = "Search Surah..."
    static let searchVerse = "Search Verse..."
    static let back = "Back"
    static let cancel = "Cancel"
    static let verses = "verses"
    static let verseCount = "%d verses"
    static let noResults = "No results found"
    static let searchPlaceholder = "Search by name or number..."
}
