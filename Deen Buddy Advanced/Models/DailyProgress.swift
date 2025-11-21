//
//  DailyProgress.swift
//  Deen Buddy Advanced
//
//  Data models for daily progress tracking system
//

import Foundation

// MARK: - Activity Type
enum DailyActivityType: String, Codable, CaseIterable {
    case verse = "daily_verse"
    case durood = "daily_durood"
    case dua = "daily_dua"
    case wisdom = "daily_wisdom"

    var displayName: String {
        switch self {
        case .verse: return AppStrings.today.dailyVerseActivity
        case .durood: return AppStrings.today.dailyDuroodActivity
        case .dua: return AppStrings.today.dailyDuaActivity
        case .wisdom: return AppStrings.today.dailyWisdomActivity
        }
    }

    var estimatedMinutes: Int {
        switch self {
        case .verse: return 2
        case .durood: return 2
        case .dua: return 2
        case .wisdom: return 2
        }
    }

    var iconName: String {
        switch self {
        case .verse: return "book.fill"
        case .durood: return "hands.sparkles.fill"
        case .dua: return "heart.fill"
        case .wisdom: return "quote.bubble.fill"
        }
    }
}

// MARK: - Daily Activity Content
struct DailyActivityContent: Codable {
    let id: String
    let type: DailyActivityType
    let title: String
    let arabicText: String?  // Optional for wisdom type
    let transliteration: String?
    let translation: String
    let reference: String?
    let tags: [String]

    init(id: String = UUID().uuidString,
         type: DailyActivityType,
         title: String,
         arabicText: String? = nil,  // Now optional
         transliteration: String? = nil,
         translation: String,
         reference: String? = nil,
         tags: [String] = []) {
        self.id = id
        self.type = type
        self.title = title
        self.arabicText = arabicText
        self.transliteration = transliteration
        self.translation = translation
        self.reference = reference
        self.tags = tags
    }
}

// MARK: - Daily Completion Record
struct DailyCompletionRecord: Codable {
    var date: Date
    var completedActivities: Set<DailyActivityType>
    var completionTimes: [DailyActivityType: Date]

    init(date: Date = Date(), completedActivities: Set<DailyActivityType> = [], completionTimes: [DailyActivityType: Date] = [:]) {
        self.date = date
        self.completedActivities = completedActivities
        self.completionTimes = completionTimes
    }

    var isFullyCompleted: Bool {
        completedActivities.count == DailyActivityType.allCases.count
    }

    var progressPercentage: Int {
        let completed = completedActivities.count
        let total = DailyActivityType.allCases.count
        return total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
    }
}

// MARK: - Daily Progress Tracker
struct DailyProgressTracker: Codable {
    var completionHistory: [String: DailyCompletionRecord]  // Date key (yyyyMMdd) -> Record
    var currentStreak: Int
    var bestStreak: Int

    init() {
        self.completionHistory = [:]
        self.currentStreak = 0
        self.bestStreak = 0
    }

    // MARK: - Today's Data

    var todayRecord: DailyCompletionRecord {
        let key = dateKey(from: Date())
        return completionHistory[key] ?? DailyCompletionRecord()
    }

    var todayProgress: Int {
        return todayRecord.progressPercentage
    }

    func isActivityCompleted(_ type: DailyActivityType) -> Bool {
        return todayRecord.completedActivities.contains(type)
    }

    // MARK: - Streak Calculation

    mutating func calculateStreaks() {
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0

        // Calculate current streak (from today backwards)
        while true {
            let key = dateKey(from: currentDate)
            if let record = completionHistory[key], record.isFullyCompleted {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }

        self.currentStreak = streak

        // Calculate best streak
        let sortedRecords = completionHistory.sorted { $0.key < $1.key }
        var maxStreak = 0
        var tempStreak = 0

        for (_, record) in sortedRecords {
            if record.isFullyCompleted {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }

        self.bestStreak = max(maxStreak, currentStreak)
    }

    // MARK: - Weekly Streak Data

    func getLast7Days() -> [Bool] {
        let calendar = Calendar.current
        var days: [Bool] = []

        // Get today's weekday (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
        let todayWeekday = calendar.component(.weekday, from: Date())

        // Calculate how many days back to go to reach Sunday
        let daysBackToSunday = todayWeekday - 1

        // Start from this week's Sunday
        guard let sunday = calendar.date(byAdding: .day, value: -daysBackToSunday, to: Date()) else {
            return Array(repeating: false, count: 7)
        }

        // Get completion status for each day from Sunday to Saturday
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: sunday) else {
                days.append(false)
                continue
            }
            let key = dateKey(from: date)
            let record = completionHistory[key]
            days.append(record?.isFullyCompleted ?? false)
        }

        return days
    }

    // MARK: - Mark Activity Complete

    mutating func markActivityComplete(_ type: DailyActivityType, for date: Date = Date()) {
        let key = dateKey(from: date)
        var record = completionHistory[key] ?? DailyCompletionRecord(date: date)

        record.completedActivities.insert(type)
        record.completionTimes[type] = Date()

        completionHistory[key] = record
        calculateStreaks()
    }

    // MARK: - Helper

    func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}
