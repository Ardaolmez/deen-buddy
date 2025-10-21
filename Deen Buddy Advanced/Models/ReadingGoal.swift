//
//  ReadingGoal.swift
//  Deen Buddy Advanced
//
//  Data models for daily reading goal system
//

import Foundation

// MARK: - Goal Type
enum ReadingGoalType: String, Codable, CaseIterable {
    case completion1Week = "1_week"
    case completion2Weeks = "2_weeks"
    case completion1Month = "1_month"
    case completion3Months = "3_months"
    case microLearning5Minutes = "5_minutes"

    var displayName: String {
        switch self {
        case .completion1Week: return "1 Week"
        case .completion2Weeks: return "2 Weeks"
        case .completion1Month: return "1 Month"
        case .completion3Months: return "3 Months"
        case .microLearning5Minutes: return "5 Minutes Daily"
        }
    }

    var versesPerDay: Int {
        let totalVerses = 6236
        switch self {
        case .completion1Week: return totalVerses / 7     // ~891 verses
        case .completion2Weeks: return totalVerses / 14   // ~445 verses
        case .completion1Month: return totalVerses / 30   // ~208 verses
        case .completion3Months: return totalVerses / 90  // ~69 verses
        case .microLearning5Minutes: return 0  // Time-based, not verse-based
        }
    }

    var minutesPerDay: Int {
        switch self {
        case .microLearning5Minutes: return 5
        default: return 0  // Completion goals are verse-based
        }
    }

    var isTimeBased: Bool {
        return self == .microLearning5Minutes
    }
}

// MARK: - Daily Activity
struct DailyActivity: Codable {
    var versesRead: Int
    var versesListened: Int
    var minutesRead: Int
    var minutesListened: Int

    var totalVerses: Int {
        versesRead + versesListened
    }

    var totalMinutes: Int {
        minutesRead + minutesListened
    }

    init(versesRead: Int = 0, versesListened: Int = 0, minutesRead: Int = 0, minutesListened: Int = 0) {
        self.versesRead = versesRead
        self.versesListened = versesListened
        self.minutesRead = minutesRead
        self.minutesListened = minutesListened
    }
}

// MARK: - Reading Goal
struct ReadingGoal: Codable {
    var goalType: ReadingGoalType
    var startDate: Date
    var currentVersePosition: Int  // Absolute position in Quran (1-6236)
    var dailyActivity: [String: DailyActivity]  // Date key -> Activity
    var dailyGoalCompleted: [String: Bool]  // Date key -> Completion status

    // MARK: - Computed Properties

    var daysElapsed: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, days)
    }

    var expectedVersePosition: Int {
        return min(goalType.versesPerDay * daysElapsed, 6236)
    }

    var versesDifference: Int {
        return currentVersePosition - expectedVersePosition
    }

    var isAhead: Bool {
        return versesDifference > 0
    }

    var isBehind: Bool {
        return versesDifference < 0
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        while true {
            let key = dateKey(from: checkDate)
            if dailyGoalCompleted[key] == true {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }

    var bestStreak: Int {
        let sorted = dailyGoalCompleted.sorted { $0.key < $1.key }
        var maxStreak = 0
        var currentStreak = 0

        for (_, completed) in sorted {
            if completed {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    // MARK: - Today's Data

    var todayActivity: DailyActivity {
        let key = dateKey(from: Date())
        return dailyActivity[key] ?? DailyActivity()
    }

    var todayCompleted: Bool {
        let key = dateKey(from: Date())
        return dailyGoalCompleted[key] ?? false
    }

    var todayRemainingVerses: Int {
        return max(0, goalType.versesPerDay - todayActivity.totalVerses)
    }

    var todayRemainingMinutes: Int {
        return max(0, goalType.minutesPerDay - todayActivity.totalMinutes)
    }

    // MARK: - Helpers

    func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }

    // MARK: - Initialization

    init(goalType: ReadingGoalType, startDate: Date = Date()) {
        self.goalType = goalType
        self.startDate = startDate
        self.currentVersePosition = 0
        self.dailyActivity = [:]
        self.dailyGoalCompleted = [:]
    }
}

// MARK: - Current Position Info
struct CurrentPositionInfo {
    let surahName: String
    let surahTransliteration: String
    let verseNumber: Int
    let absoluteVersePosition: Int
    let totalVerses: Int

    var displayText: String {
        return "\(surahTransliteration): \(verseNumber)"
    }

    var detailText: String {
        return "Verse \(absoluteVersePosition) of \(totalVerses)"
    }
}
