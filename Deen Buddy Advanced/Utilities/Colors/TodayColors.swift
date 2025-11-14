//
//  TodayColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Today tab
//

import SwiftUI

extension AppColors {

    // MARK: - Today Tab Colors
    struct Today {
        // Brand color - Forest green (matches Chat and app theme)
        static let brandGreen = Color(red: 0.29, green: 0.55, blue: 0.42)

        // Quiz button - now uses brand green theme
        static let dailyQuizButton = brandGreen
        static let dailyQuizText = Color.white

        // Quiz question circles
        static let quizCircleCorrect = brandGreen
        static let quizCircleIncorrect = Color(red: 0.85, green: 0.45, blue: 0.42) // Pastel red matching green's vibrancy
        static let quizCircleUnanswered = papyrusBackground // Same as background
        static let quizCircleBorder = Color(.systemGray4)
        static let quizCircleNumber = Color.primary
        static let quizCircleIcon = Color.white

        // Streak colors - warm orange/gold theme
        static let streakFlame = Color(red: 1.0, green: 0.6, blue: 0.2) // Warm orange
        static let streakActive = brandGreen // Changed from generic green to brand green
        static let streakInactive = Color(.systemGray5)
        static let streakText = Color.secondary

        static let cardBackground = Color.black
        static let cardShadow = Color.black.opacity(0.05)

        static let settingsIcon = brandGreen // Changed to match brand

        // Personalized Learning Card
        static let learningIcon = brandGreen // Changed to match brand
        static let learningButton = brandGreen // Changed to match brand
        static let learningButtonText = Color.white

        // Prayer Time Compact Widget
        static let prayerCompactIcon =   Color(red: 0.29, green: 0.55, blue: 0.42)// Warm orange to match streak

        // Daily Reading Goal Card
        static let quranGoalTitle = Color.primary
        static let quranGoalMetric = Color.secondary
        static let quranGoalPosition = Color.primary
        static let quranGoalSurah = Color.primary
        static let quranGoalVerse = Color.secondary
        static let quranGoalStatusAhead = brandGreen // Changed to brand green
        static let quranGoalStatusBehind = Color(red: 1.0, green: 0.6, blue: 0.2) // Warm orange
        static let quranGoalStatusOnTrack = brandGreen // Changed to brand green
        static let quranGoalRemaining = Color.secondary

        // Brand color reference (keeping for backward compatibility)
        static let quranGoalBrandColor = brandGreen

        static let quranGoalButtonRead = brandGreen // Changed to brand green
        static let quranGoalButtonListen = Color(red: 0.35, green: 0.65, blue: 0.52) // Lighter green variant
        static let quranGoalButtonText = Color.white
        static let quranGoalButtonBorder = Color(.systemGray4)
        static let quranGoalExpandHint = Color.secondary
        static let quranGoalDivider = Color(.systemGray4)
        static let quranGoalSectionHeader = Color.secondary
        static let quranGoalDetailText = Color.primary

        // Daily Verse Card - updated to warm theme
        static let verseCardPrimaryText = Color.white
        static let verseCardSecondaryText = Color.white.opacity(0.8)
        static let verseCardGradientStart = brandGreen.opacity(0.8) // Brand green
        static let verseCardGradientEnd = Color(red: 0.35, green: 0.65, blue: 0.52).opacity(0.6) // Lighter green
        static let verseCardShadow = Color.black
        static let verseCardProgressTint = Color.white

        // Reading Goal Card - Text and Shadows
        static let quranGoalCardText = Color.white
        static let quranGoalCardShadow = Color.black
        static let quranGoalOverlayBackground = Color.black

        // Daily Progress Cards
        static let activityCardBackground = Color(.systemBackground)
        static let activityCardBorder = Color(.systemGray4)
        static let activityCardTitle = Color.primary
        static let activityCardTime = Color.secondary
        static let activityCardDone = brandGreen // Changed to brand green
        static let activityCardIcon = brandGreen // Changed to brand green
        static let activityCardIconBackground = brandGreen.opacity(0.1) // Changed to brand green

        // Progress Bar - warm orange/gold gradient
        static let progressBarBackground = Color(.systemGray5)
        static let progressBarFill = Color(red: 1.0, green: 0.6, blue: 0.2) // Warm orange to match streak
        static let progressText = Color.primary

        // Activity Detail Modal
        static let modalBackground = Color(.systemBackground)
        static let modalOverlay = Color.black.opacity(0.3)
        static let modalArabicText = Color.primary
        static let modalTranslationText = Color.secondary
        static let modalReferenceText = Color.secondary
        static let modalTagBackground = brandGreen.opacity(0.1) // Changed to brand green
        static let modalTagText = brandGreen // Changed to brand green
        static let completeButton = brandGreen // Changed to brand green
        static let completeButtonText = Color.white

        // MARK: - Background & Overlays
        static let papyrusBackground = Color(red: 0.98, green: 0.97, blue: 0.95)
        static let darkOverlay = Color.black.opacity(0.6)
        static let darkOverlayLight = Color.black.opacity(0.4)
        static let darkOverlayMedium = Color.black.opacity(0.5)

        // MARK: - Gradients & Overlays (excluding shadows)
        static let gradientOverlayLight = Color.black.opacity(0.2)
        static let gradientOverlayMedium = Color.black.opacity(0.3)
        static let gradientOverlayDark = Color.black.opacity(0.4)

        // MARK: - Fallback Gradients (when images don't load)
        static let fallbackGradientStart = Color(red: 0.4, green: 0.45, blue: 0.5)
        static let fallbackGradientMid = Color(red: 0.3, green: 0.4, blue: 0.45)
        static let fallbackGradientEnd = Color(red: 0.2, green: 0.3, blue: 0.35)
        static let fallbackGradientPurpleStart = Color(red: 0.4, green: 0.3, blue: 0.6)
        static let fallbackGradientPurpleEnd = Color(red: 0.3, green: 0.2, blue: 0.5)

        // MARK: - Button Frosted Glass Overlays
        static let buttonFrostedOverlay = Color.black.opacity(0.1)
        static let buttonWhiteOverlay = Color.white.opacity(0.2)
        static let buttonWhiteOverlayLight = Color.white.opacity(0.3)
        static let buttonWhiteOverlayCircle = Color.white.opacity(0.25)

        // MARK: - Wisdom Card Colors
        static let wisdomQuoteMark = Color.orange.opacity(0.3)
        static let wisdomQuoteText = Color.white
        static let wisdomAuthorLine = Color.orange.opacity(0.6)
        static let wisdomAuthorText = Color.white.opacity(0.9)
        static let wisdomUnderstandingIcon = Color.yellow
        static let wisdomUnderstandingLabel = Color.yellow
        static let wisdomDividerStart = Color.white.opacity(0.0)
        static let wisdomDividerMid = Color.white.opacity(0.3)

        // MARK: - Separator Gradient Colors
        static let separatorGradientColor = Color(red: 0.95, green: 0.8, blue: 0.6)
        static let separatorIconColor = Color(red: 0.9, green: 0.7, blue: 0.3)

        // MARK: - Streak Feedback Overlay
        static let streakFeedbackBackground = Color.black
        static let streakFeedbackCount = Color(red: 0.85, green: 0.65, blue: 0.13)
        static let streakFeedbackText = Color(red: 0.85, green: 0.65, blue: 0.13)
        static let streakFeedbackEncouragement = Color.white
        static let streakFeedbackDayInactive = Color.white.opacity(0.2)
        static let streakFeedbackCalendarBg = Color.white.opacity(0.1)
        static let streakFeedbackButton = Color(red: 0.85, green: 0.65, blue: 0.13)
        static let streakFeedbackButtonText = Color.black
        static let streakFeedbackDayText = Color.white.opacity(0.6)
        static let streakFeedbackDayNumber = Color.white.opacity(0.5)

        // MARK: - Activity Detail Screen
        static let activityDetailProgressPercent = Color.yellow
        static let activityDetailProgressGradientStart = Color.orange
        static let activityDetailProgressGradientEnd = Color.yellow
        static let activityDetailReference = Color.orange
        static let activityDetailTranslationLabel = Color.orange
        static let activityDetailShareBg = Color.white.opacity(0.2)
        static let activityDetailChatBg = Color.white.opacity(0.2)
        static let activityDetailNextButton = Color.white
        static let activityDetailNextButtonText = Color.black

        // MARK: - Simple Activity Card
        static let activityCardCompletionBg = Color.green.opacity(0.2)
        static let activityCardCompletionIcon = Color.white
        static let activityCardWhiteIcon = Color.white.opacity(0.3)
        static let activityCardExpandedOverlay = Color.black.opacity(0.5)
        static let activityCardCollapsedOverlay = Color.black.opacity(0.5)
        static let activityCardExpandedGradientLight = Color.white.opacity(0.15)
        static let activityCardExpandedGradientDark = Color.white.opacity(0.05)
        static let activityCardCollapsedGradientLight = Color.black.opacity(0.2)
        static let activityCardCollapsedGradientDark = Color.black.opacity(0.4)

        // MARK: - Journey Header (Legacy)
        static let journeyAvatarGradientStart = Color(red: 0.8, green: 0.7, blue: 0.3)
        static let journeyAvatarGradientEnd = Color(red: 0.9, green: 0.8, blue: 0.4)
        static let journeyHeaderTitle = AppColors.Today.activityCardTitle
        static let journeyHeaderDate = AppColors.Today.activityCardTitle

        // MARK: - Progress Bar Background
        static let progressBarBackgroundTan = Color(red: 0.95, green: 0.93, blue: 0.88)

        // MARK: - Weekly Streak Progress
        static let weeklyStreakBorder = Color(.systemGray3)
        static let weeklyStreakBorderInactive = Color(.systemGray4)
        static let weeklyStreakBackground = Color(.systemGray5)
        static let weeklyStreakBackgroundInactive = Color(.systemGray6)

        // MARK: - Prayer Compact Widget
        static let prayerCompactBackground = Color(.systemGray6)

        // MARK: - Feedback Screen
        static let feedbackPlaceholder = Color.gray
        static let feedbackTextEditor = Color.black
        static let feedbackBackground = Color.white
        static let feedbackBorder = Color.gray.opacity(0.3)
        static let feedbackTint = Color.green
    }
}
