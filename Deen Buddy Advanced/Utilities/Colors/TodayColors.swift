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
    }
}
