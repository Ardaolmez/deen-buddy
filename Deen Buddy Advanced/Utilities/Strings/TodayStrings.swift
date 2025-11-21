//
//  TodayStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Today tab
//

import Foundation

private let table = "Today"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct TodayStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var selfLearningTitle: String { lang.getString("selfLearningTitle", table: table) }
    static var dailyQuiz: String { lang.getString("dailyQuiz", table: table) }
    static var startLesson: String { lang.getString("startLesson", table: table) }
    static var continueJourney: String { lang.getString("continueJourney", table: table) }

    // Daily Verse Card
    static var dailyVerseTitle: String { lang.getString("dailyVerseTitle", table: table) }

    // Daily Quran Goal Card
    static var dailyQuranGoal: String { lang.getString("dailyQuranGoal", table: table) }
    static var verses: String { lang.getString("verses", table: table) }
    static var minutes: String { lang.getString("minutes", table: table) }
    static var pages: String { lang.getString("pages", table: table) }
    static var versesAhead: String { lang.getString("versesAhead", table: table) }
    static var versesBehind: String { lang.getString("versesBehind", table: table) }
    static var minutesAhead: String { lang.getString("minutesAhead", table: table) }
    static var minutesBehind: String { lang.getString("minutesBehind", table: table) }
    static var onTrack: String { lang.getString("onTrack", table: table) }
    static var versesToGo: String { lang.getString("versesToGo", table: table) }
    static var minutesToGo: String { lang.getString("minutesToGo", table: table) }
    static var read: String { lang.getString("read", table: table) }
    static var listen: String { lang.getString("listen", table: table) }
    static var tapForDetails: String { lang.getString("tapForDetails", table: table) }
    static var tapToCollapse: String { lang.getString("tapToCollapse", table: table) }

    // Reading Goal Details (Expanded)
    static var todaysProgress: String { lang.getString("todaysProgress", table: table) }
    static var goal: String { lang.getString("goal", table: table) }
    static var completed: String { lang.getString("completed", table: table) }
    static var remaining: String { lang.getString("remaining", table: table) }
    static var timeline: String { lang.getString("timeline", table: table) }
    static var expected: String { lang.getString("expected", table: table) }
    static var actual: String { lang.getString("actual", table: table) }
    static var status: String { lang.getString("status", table: table) }
    static var streak: String { lang.getString("streak", table: table) }
    static var current: String { lang.getString("current", table: table) }
    static var best: String { lang.getString("best", table: table) }
    static var days: String { lang.getString("days", table: table) }
    static var day: String { lang.getString("day", table: table) }

    // Reading Goal Selection
    static var selectYourGoal: String { lang.getString("selectYourGoal", table: table) }
    static var completionGoals: String { lang.getString("completionGoals", table: table) }
    static var microLearningGoals: String { lang.getString("microLearningGoals", table: table) }
    static var startGoal: String { lang.getString("startGoal", table: table) }
    static var cancel: String { lang.getString("cancel", table: table) }

    // Reading Goal Assets (not localized - file names)
    static let mosquePaintingImage = "Quba mosque painting.jpg"
    static var versePrefix: String { lang.getString("versePrefix", table: table) }

    // Daily Verse Assets (not localized - file names)
    static let tileBackgroundImage = "tile.jpg"

    // Daily Verse Errors
    static var couldNotLoadQuranData: String { lang.getString("couldNotLoadQuranData", table: table) }
    static var couldNotSelectDailyVerse: String { lang.getString("couldNotSelectDailyVerse", table: table) }

    // Daily Verse Card
    static var tapToReadFull: String { lang.getString("tapToReadFull", table: table) }

    // Feedback Messages
    static var feedbackThankYou: String { lang.getString("feedbackThankYou", table: table) }
    static var feedbackError: String { lang.getString("feedbackError", table: table) }

    // Daily Progress
    static var progressToday: String { lang.getString("progressToday", table: table) }
    static var dailyStreakTitle: String { lang.getString("dailyStreakTitle", table: table) }
    static var currentStreak: String { lang.getString("currentStreak", table: table) }
    static var bestStreakLabel: String { lang.getString("bestStreakLabel", table: table) }
    static var dayStreak: String { lang.getString("dayStreak", table: table) }
    static var daysStreak: String { lang.getString("daysStreak", table: table) }

    // Daily Activities
    static var dailyVerseActivity: String { lang.getString("dailyVerseActivity", table: table) }
    static var dailyDuroodActivity: String { lang.getString("dailyDuroodActivity", table: table) }
    static var dailyDuaActivity: String { lang.getString("dailyDuaActivity", table: table) }
    static var dailyWisdomActivity: String { lang.getString("dailyWisdomActivity", table: table) }
    static var estimatedTime: String { lang.getString("estimatedTime", table: table) }
    static var learnSomethingNew: String { lang.getString("learnSomethingNew", table: table) }
    static var activityDone: String { lang.getString("activityDone", table: table) }
    static var markComplete: String { lang.getString("markComplete", table: table) }
    static var listenLabel: String { lang.getString("listenLabel", table: table) }
    static var readLabel: String { lang.getString("readLabel", table: table) }
    static var closeLabel: String { lang.getString("closeLabel", table: table) }

    // MARK: - Daily Quiz Button
    static var dailyQuizLabel: String { lang.getString("dailyQuizLabel", table: table) }
    static var dailyQuizMinutes: String { lang.getString("dailyQuizMinutes", table: table) }
    static var dailyQuizStart: String { lang.getString("dailyQuizStart", table: table) }
    static var dailyQuizContinue: String { lang.getString("dailyQuizContinue", table: table) }
    static var dailyQuizReview: String { lang.getString("dailyQuizReview", table: table) }
    static var dailyQuizSubmit: String { lang.getString("dailyQuizSubmit", table: table) }

    // MARK: - Activity Detail Screen
    static var activityProgressToday: String { lang.getString("activityProgressToday", table: table) }
    static var activityTranslationLabel: String { lang.getString("activityTranslationLabel", table: table) }
    static var activityExplanationLabel: String { lang.getString("activityExplanationLabel", table: table) }
    static var activityChatToLearnMore: String { lang.getString("activityChatToLearnMore", table: table) }
    static var activityTodaysJourney: String { lang.getString("activityTodaysJourney", table: table) }

    // MARK: - Word of Wisdom
    static var wisdomUnderstanding: String { lang.getString("wisdomUnderstanding", table: table) }
    static var wisdomChatPromptPrefix: String { lang.getString("wisdomChatPromptPrefix", table: table) }
    static var wisdomChatQuoteLabel: String { lang.getString("wisdomChatQuoteLabel", table: table) }
    static var wisdomChatExplanationLabel: String { lang.getString("wisdomChatExplanationLabel", table: table) }
    static var wisdomChatRequestDetails: String { lang.getString("wisdomChatRequestDetails", table: table) }
    static var wisdomShareTitle: String { lang.getString("wisdomShareTitle", table: table) }
    static var wisdomShareFooter: String { lang.getString("wisdomShareFooter", table: table) }

    // MARK: - Streak Feedback Overlay
    static var streakDayLabel: String { lang.getString("streakDayLabel", table: table) }
    static var streakEncouragement: String { lang.getString("streakEncouragement", table: table) }
    static var streakDoneButton: String { lang.getString("streakDoneButton", table: table) }
    // Day abbreviations - localized
    static var streakDayAbbreviations: [String] {
        switch lang.currentLanguage {
        case .turkish:
            return ["Pz", "Pt", "Sa", "Ça", "Pe", "Cu", "Ct"]
        default:
            return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        }
    }

    // MARK: - Locked Day View
    static var lockedNotQuiteTime: String { lang.getString("lockedNotQuiteTime", table: table) }
    static var lockedCheckBackOn: String { lang.getString("lockedCheckBackOn", table: table) }
    static var lockedDontMissDay: String { lang.getString("lockedDontMissDay", table: table) }
    static var lockedSetReminder: String { lang.getString("lockedSetReminder", table: table) }

    // MARK: - Journey Header
    static var journeyTodayTitle: String { lang.getString("journeyTodayTitle", table: table) }
    static var journeyDateSuffix: String { lang.getString("journeyDateSuffix", table: table) }

    // MARK: - Activity Cards
    static var activityDoneLabel: String { lang.getString("activityDoneLabel", table: table) }
    static var activityListenButton: String { lang.getString("activityListenButton", table: table) }
    static var activityReadButton: String { lang.getString("activityReadButton", table: table) }

    // MARK: - Feedback Screen
    static var feedbackTitle: String { lang.getString("feedbackTitle", table: table) }
    static var feedbackHeaderTitle: String { lang.getString("feedbackHeaderTitle", table: table) }
    static var feedbackHeaderSubtitle: String { lang.getString("feedbackHeaderSubtitle", table: table) }
    static var feedbackPlaceholder: String { lang.getString("feedbackPlaceholder", table: table) }
    static var feedbackSubmitButton: String { lang.getString("feedbackSubmitButton", table: table) }
    static var feedbackCancelButton: String { lang.getString("feedbackCancelButton", table: table) }
    static var feedbackNetworkError: String { lang.getString("feedbackNetworkError", table: table) }
    static var feedbackDataError: String { lang.getString("feedbackDataError", table: table) }
    static var feedbackServerError: String { lang.getString("feedbackServerError", table: table) }

    // MARK: - Reading Goal Tracking
    static var trackingSaveButton: String { lang.getString("trackingSaveButton", table: table) }

    // MARK: - Component Labels
    static var weeklyStreakProgressFor: String { lang.getString("weeklyStreakProgressFor", table: table) }
}
