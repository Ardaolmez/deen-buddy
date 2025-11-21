//
//  QuizStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Quiz tab
//

import Foundation

private let table = "Quiz"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct QuizStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var nextQuestion: String { lang.getString("nextQuestion", table: table) }
    static var seeResults: String { lang.getString("seeResults", table: table) }

    // Quiz Result
    static var yourIman: String { lang.getString("yourIman", table: table) }
    static var retry: String { lang.getString("retry", table: table) }
    static var share: String { lang.getString("share", table: table) }
    static var tailoredQuizzes: String { lang.getString("tailoredQuizzes", table: table) }

    // Grade Messages
    static var gradeExcellent: String { lang.getString("gradeExcellent", table: table) }
    static var gradeGreat: String { lang.getString("gradeGreat", table: table) }
    static var gradeGood: String { lang.getString("gradeGood", table: table) }
    static var gradeKeepGoing: String { lang.getString("gradeKeepGoing", table: table) }

    // Share
    static var shareText: String { lang.getString("shareText", table: table) }

    // Answer Feedback
    static var correct: String { lang.getString("correct", table: table) }
    static var incorrect: String { lang.getString("incorrect", table: table) }
    static var correctAnswerIs: String { lang.getString("correctAnswerIs", table: table) }
    static var explanation: String { lang.getString("explanation", table: table) }
    static var reference: String { lang.getString("reference", table: table) }
    static var yourAnswer: String { lang.getString("yourAnswer", table: table) }
    static var correctAnswer: String { lang.getString("correctAnswer", table: table) }

    // Verse Display
    static var quranVerse: String { lang.getString("quranVerse", table: table) }

    // Verse Popup
    static var versePopupDone: String { lang.getString("versePopupDone", table: table) }
    static var versePopupLoading: String { lang.getString("versePopupLoading", table: table) }
    static var versePopupError: String { lang.getString("versePopupError", table: table) }
    static var verseLabel: String { lang.getString("verseLabel", table: table) }
}
