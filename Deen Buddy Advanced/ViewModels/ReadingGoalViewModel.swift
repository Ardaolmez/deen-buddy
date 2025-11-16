//
//  ReadingGoalViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for managing daily reading goals
//

import Foundation
import SwiftUI
import Combine

class ReadingGoalViewModel: ObservableObject {
    static let shared = ReadingGoalViewModel()

    @Published var readingGoal: ReadingGoal?
    @Published var currentPositionInfo: CurrentPositionInfo?

    private let userDefaults = UserDefaults.standard
    private let goalKey = "readingGoal"
    private let lastPositionKey = "lastReadPosition"
    private var surahs: [Surah] = []

    private init() {
        loadSurahs()
        loadGoal()
        updateCurrentPosition()
    }

    // MARK: - Data Loading

    private func loadSurahs() {
        surahs = QuranService.shared.loadQuran()
    }

    func loadGoal() {
        guard let data = userDefaults.data(forKey: goalKey),
              let goal = try? JSONDecoder().decode(ReadingGoal.self, from: data) else {
            return
        }
        readingGoal = goal
    }

    private func saveGoal() {
        guard let goal = readingGoal,
              let data = try? JSONEncoder().encode(goal) else {
            return
        }
        userDefaults.set(data, forKey: goalKey)
    }

    // MARK: - Goal Management

    func createGoal(type: ReadingGoalType) {
        readingGoal = ReadingGoal(goalType: type, startDate: Date())
        saveGoal()
        updateCurrentPosition()
    }

    func deleteGoal() {
        readingGoal = nil
        currentPositionInfo = nil
        userDefaults.removeObject(forKey: goalKey)
    }

    // MARK: - Position Tracking

    func updateCurrentPosition() {
        guard let goal = readingGoal else {
            currentPositionInfo = nil
            return
        }

        let position = goal.currentVersePosition
        if let info = getPositionInfo(for: position) {
            currentPositionInfo = info
        }
    }

    private func getPositionInfo(for absolutePosition: Int) -> CurrentPositionInfo? {
        guard !surahs.isEmpty else { return nil }

        var currentPosition = 0
        for surah in surahs {
            let surahVerseCount = surah.verses.count
            if currentPosition + surahVerseCount > absolutePosition {
                let verseInSurah = absolutePosition - currentPosition
                return CurrentPositionInfo(
                    surahID: surah.id,
                    surahName: surah.name,
                    surahTransliteration: surah.transliteration,
                    verseNumber: verseInSurah + 1,  // Verses are 1-indexed for display
                    absoluteVersePosition: absolutePosition,
                    totalVerses: 6236
                )
            }
            currentPosition += surahVerseCount
        }

        // If position is beyond total verses, return last verse
        if let lastSurah = surahs.last {
            return CurrentPositionInfo(
                surahID: lastSurah.id,
                surahName: lastSurah.name,
                surahTransliteration: lastSurah.transliteration,
                verseNumber: lastSurah.verses.count,
                absoluteVersePosition: 6236,
                totalVerses: 6236
            )
        }

        return nil
    }

    // MARK: - Activity Tracking

    func recordReadingActivity(verses: Int, minutes: Int) {
        guard var goal = readingGoal else { return }

        let key = goal.dateKey(from: Date())
        var activity = goal.dailyActivity[key] ?? DailyActivity()

        activity.versesRead += verses
        activity.minutesRead += minutes

        goal.dailyActivity[key] = activity
        // Don't update position here - it's already being tracked by the reading views

        // Check if today's goal is completed
        if goal.goalType.isTimeBased {
            if activity.totalMinutes >= goal.goalType.minutesPerDay {
                goal.dailyGoalCompleted[key] = true
            }
        } else {
            if activity.totalVerses >= goal.goalType.versesPerDay {
                goal.dailyGoalCompleted[key] = true
            }
        }

        readingGoal = goal
        saveGoal()
        updateCurrentPosition()
    }

    func recordListeningActivity(verses: Int, minutes: Int) {
        guard var goal = readingGoal else { return }

        let key = goal.dateKey(from: Date())
        var activity = goal.dailyActivity[key] ?? DailyActivity()

        activity.versesListened += verses
        activity.minutesListened += minutes

        goal.dailyActivity[key] = activity
        // Don't update position here - it's already being tracked by the reading views

        // Check if today's goal is completed
        if goal.goalType.isTimeBased {
            if activity.totalMinutes >= goal.goalType.minutesPerDay {
                goal.dailyGoalCompleted[key] = true
            }
        } else {
            if activity.totalVerses >= goal.goalType.versesPerDay {
                goal.dailyGoalCompleted[key] = true
            }
        }

        readingGoal = goal
        saveGoal()
        updateCurrentPosition()
    }

    // MARK: - Display Helpers

    var goalMetricText: String {
        guard let goal = readingGoal else { return "" }

        if goal.goalType.isTimeBased {
            return "\(goal.goalType.minutesPerDay) \(AppStrings.today.minutes)"
        } else {
            return "\(goal.goalType.versesPerDay) \(AppStrings.today.verses)"
        }
    }

    var statusText: String {
        guard let goal = readingGoal else { return "" }

        if goal.goalType.isTimeBased {
            let diff = goal.todayActivity.totalMinutes - goal.goalType.minutesPerDay
            if diff > 0 {
                return String(format: AppStrings.today.minutesAhead, diff)
            } else if diff < 0 {
                return String(format: AppStrings.today.minutesBehind, abs(diff))
            } else {
                return AppStrings.today.onTrack
            }
        } else {
            if goal.isAhead {
                return String(format: AppStrings.today.versesAhead, goal.versesDifference)
            } else if goal.isBehind {
                return String(format: AppStrings.today.versesBehind, abs(goal.versesDifference))
            } else {
                return AppStrings.today.onTrack
            }
        }
    }

    var statusColor: Color {
        guard let goal = readingGoal else { return AppColors.Today.quranGoalStatusOnTrack }

        if goal.isAhead {
            return AppColors.Today.quranGoalStatusAhead
        } else if goal.isBehind {
            return AppColors.Today.quranGoalStatusBehind
        } else {
            return AppColors.Today.quranGoalStatusOnTrack
        }
    }

    var remainingText: String {
        guard let goal = readingGoal else { return "" }

        if goal.goalType.isTimeBased {
            return String(format: AppStrings.today.minutesToGo, goal.todayRemainingMinutes)
        } else {
            return String(format: AppStrings.today.versesToGo, goal.todayRemainingVerses)
        }
    }

    // MARK: - Session Management

    func saveLastReadPosition(surahId: Int, verseId: Int) {
        let position = ["surahId": surahId, "verseId": verseId]
        userDefaults.set(position, forKey: lastPositionKey)
    }

    func getLastReadPosition() -> (surahId: Int, verseId: Int)? {
        guard let position = userDefaults.dictionary(forKey: lastPositionKey),
              let surahId = position["surahId"] as? Int,
              let verseId = position["verseId"] as? Int else {
            return nil
        }
        return (surahId, verseId)
    }

    func getAbsolutePosition(surahId: Int, verseId: Int) -> Int {
        var absolutePos = 0

        for surah in surahs {
            if surah.id == surahId {
                // Find the verse in this surah
                if let verseIndex = surah.verses.firstIndex(where: { $0.id == verseId }) {
                    return absolutePos + verseIndex
                }
                return absolutePos
            }
            absolutePos += surah.verses.count
        }

        return 0
    }

    func updateCurrentPosition(to position: Int) {
        guard var goal = readingGoal else { return }
        goal.currentVersePosition = position
        readingGoal = goal
        saveGoal()
        updateCurrentPosition()
    }

    func getSurahs() -> [Surah] {
        return surahs
    }
}
