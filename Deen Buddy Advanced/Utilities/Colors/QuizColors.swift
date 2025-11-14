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
        // Brand color - Forest green (matches app theme)
        static let brandGreen = Color(red: 0.29, green: 0.55, blue: 0.42)

        static let nextButtonActive = brandGreen // Changed to brand green
        static let nextButtonInactive = Color.gray
        static let buttonText = Color.white


        // Quiz Result View
        static let progressBarBackground = brandGreen.opacity(0.25) // Changed to brand green
        static let progressBarFill = brandGreen // Changed to brand green
        static let resultCardBackground = Color(.systemGray6)
        static let retryButtonBackground = brandGreen.opacity(0.15) // Changed to brand green
        static let retryButtonText = brandGreen // Changed to brand green
        static let shareButtonBackground = Color.black.opacity(0.1)
        static let shareButtonText = Color.primary

        // Answer Row Colors
        static let answerText = Color.primary
        static let answerNeutralBackground = Color(.systemGray6)
        static let answerCorrectBackground = brandGreen.opacity(0.15) // Changed to brand green
        static let answerWrongBackground = Color.red.opacity(0.15)
        static let answerNeutralBorder = Color.clear
        static let answerCorrectBorder = brandGreen // Changed to brand green
        static let answerWrongBorder = Color.red

        // Feedback Colors
        static let correctAnswerBackground = brandGreen
        static let wrongAnswerBackground = Color.red

        // Explanation Card Colors
        static let explanationCardBackground = Color(.systemGray6)
        static let explanationCorrectHeader = brandGreen // Changed to brand green
        static let explanationIncorrectHeader = Color.red
        static let explanationText = Color.primary
        static let explanationReference = Color.secondary

        // Verse Display Colors
        static let verseArabicText = Color.primary
        static let verseTranslationText = Color.secondary
        static let verseCardBackground = Color(.systemBackground)

        // Verse Popup Colors
        static let referenceLink = brandGreen // Changed to brand green
        static let versePopupHighlight = Color.yellow.opacity(0.2)
        static let versePopupVerseNumber = Color.secondary

        // Progress Ring Colors
        static let progressRingBackground = Color.black.opacity(0.08)
        static let progressRingFill = brandGreen // Changed to brand green
    }
}
