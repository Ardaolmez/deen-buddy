//
//  QuizColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Quiz tab
//

import SwiftUI

extension AppColors {

    // MARK: - Quiz Tab Colors
    struct Quiz {
        static let nextButtonActive = Color.blue
        static let nextButtonInactive = Color.gray
        static let buttonText = Color.white


        // Quiz Result View
        static let progressBarBackground = Color.green.opacity(0.25)
        static let progressBarFill = Color.green
        static let resultCardBackground = Color(.systemGray6)
        static let retryButtonBackground = Color.blue.opacity(0.15)
        static let retryButtonText = Color.blue
        static let shareButtonBackground = Color.black.opacity(0.1)
        static let shareButtonText = Color.primary

        // Answer Row Colors
        static let answerText = Color.primary
        static let answerNeutralBackground = Color(.systemGray6)
        static let answerCorrectBackground = Color.green.opacity(0.15)
        static let answerWrongBackground = Color.red.opacity(0.15)
        static let answerNeutralBorder = Color.clear
        static let answerCorrectBorder = Color.green
        static let answerWrongBorder = Color.red

        // Explanation Card Colors
        static let explanationCardBackground = Color(.systemGray6)
        static let explanationCorrectHeader = Color.green
        static let explanationIncorrectHeader = Color.red
        static let explanationText = Color.primary
        static let explanationReference = Color.secondary

        // Verse Display Colors
        static let verseArabicText = Color.primary
        static let verseTranslationText = Color.secondary
        static let verseCardBackground = Color(.systemBackground)

        // Verse Popup Colors
        static let referenceLink = Color.blue
        static let versePopupHighlight = Color.yellow.opacity(0.2)
        static let versePopupVerseNumber = Color.secondary

        // Progress Ring Colors
        static let progressRingBackground = Color.black.opacity(0.08)
        static let progressRingFill = Color.green
    }
}
