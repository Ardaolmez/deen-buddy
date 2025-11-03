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
        static let dailyQuizButton = Color.blue
        static let dailyQuizText = Color.white

        static let streakFlame = Color.orange
        static let streakActive = Color.green
        static let streakInactive = Color(.systemGray5)
        static let streakText = Color.secondary

        static let cardBackground = Color.black
        static let cardShadow = Color.black.opacity(0.05)

        static let settingsIcon = Color.primary

        // Personalized Learning Card
        static let learningIcon = Color.purple
        static let learningButton = Color.purple
        static let learningButtonText = Color.white

        // Prayer Time Compact Widget
        static let prayerCompactIcon = Color.orange

        // Daily Reading Goal Card
        static let quranGoalTitle = Color.primary
        static let quranGoalMetric = Color.secondary
        static let quranGoalPosition = Color.primary
        static let quranGoalSurah = Color.primary
        static let quranGoalVerse = Color.secondary
        static let quranGoalStatusAhead = Color.green
        static let quranGoalStatusBehind = Color.orange
        static let quranGoalStatusOnTrack = Color.blue
        static let quranGoalRemaining = Color.secondary

        // Brand color - Forest green for light mode (matches ChatView)
        static let quranGoalBrandColor = Color(red: 0.29, green: 0.55, blue: 0.42)

        static let quranGoalButtonRead = Color.blue
        static let quranGoalButtonListen = Color.purple
        static let quranGoalButtonText = Color.white
        static let quranGoalButtonBorder = Color(.systemGray4)
        static let quranGoalExpandHint = Color.secondary
        static let quranGoalDivider = Color(.systemGray4)
        static let quranGoalSectionHeader = Color.secondary
        static let quranGoalDetailText = Color.primary

        // Daily Verse Card
        static let verseCardPrimaryText = Color.white
        static let verseCardSecondaryText = Color.white.opacity(0.8)
        static let verseCardGradientStart = Color.purple.opacity(0.8)
        static let verseCardGradientEnd = Color.blue.opacity(0.6)
        static let verseCardShadow = Color.black
        static let verseCardProgressTint = Color.white

        // Reading Goal Card - Text and Shadows
        static let quranGoalCardText = Color.white
        static let quranGoalCardShadow = Color.black
        static let quranGoalOverlayBackground = Color.black
    }
}
