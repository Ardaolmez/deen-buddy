//
//  AppColors.swift
//  Deen Buddy Advanced
//
//  Centralized color definitions for the entire app
//

import SwiftUI

struct AppColors {

    // MARK: - Quran Tab Colors
    struct Quran {
        // Background Gradients
        static let backgroundGradientStart = Color(red: 0.98, green: 0.94, blue: 0.82)
        static let backgroundGradientEnd = Color(red: 0.96, green: 0.92, blue: 0.78)

        // Page Background (Radial Gradient)
        static let pageCenter = Color.white
        static let pageRing1 = Color(red: 0.998, green: 0.99, blue: 0.98)
        static let pageRing2 = Color(red: 0.995, green: 0.985, blue: 0.96)
        static let pageRing3 = Color(red: 0.99, green: 0.98, blue: 0.94)
        static let pageRing4 = Color(red: 0.985, green: 0.97, blue: 0.90)

        // Text Colors
        static let toolbarText = Color.brown
        static let toolbarBackground = Color.white.opacity(0.7)

        static let surahNameArabic = Color.black
        static let surahNameTransliteration = Color.black.opacity(0.8)
        static let surahNameTranslation = Color.black.opacity(0.6)
        static let surahMetadata = Color.black.opacity(0.5)

        static let bismillah = Color.black.opacity(0.7)
        static let verseNumber = Color.black.opacity(0.6)
        static let verseText = Color.black

        // Surah Selector
        static let selectorBadgeStart = Color.green
        static let selectorBadgeEnd = Color.teal
    }

    // MARK: - Today Tab Colors
    struct Today {
        static let dailyQuizButton = Color.blue
        static let dailyQuizText = Color.white

        static let streakFlame = Color.orange
        static let streakActive = Color.green
        static let streakInactive = Color(.systemGray5)
        static let streakText = Color.secondary

        static let cardBackground = Color(.systemBackground)
        static let cardShadow = Color.black.opacity(0.05)

        static let settingsIcon = Color.primary

        // Personalized Learning Card
        static let learningIcon = Color.purple
        static let learningButton = Color.purple
        static let learningButtonText = Color.white
    }

    // MARK: - Prayers Tab Colors
    struct Prayers {
        static let headerBackground = Color(.systemGray6)
        static let headerShadow = Color.black.opacity(0.06)

        static let currentPrayerAccent = Color.green
        static let countdownBackground = Color.green.opacity(0.15)
        static let countdownText = Color.green

        static let rowCurrentBackground = Color.green.opacity(0.12)
        static let rowCurrentBorder = Color.green
        static let rowNormalBackground = Color(.systemBackground)
        static let rowNormalBorder = Color.black.opacity(0.08)

        static let completedCheckmark = Color.green
        static let uncompletedCheckmark = Color.secondary

        static let promptCompleted = Color.green
        static let promptIncomplete = Color.blue
        static let promptCompletedBackground = Color.gray.opacity(0.2)
        static let promptIncompleteBackground = Color.green.opacity(0.2)

        static let cardBackground = Color(.systemGray6)

        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
    }

    // MARK: - Quiz Tab Colors
    struct Quiz {
        static let scoreText = Color.blue
        static let nextButtonActive = Color.blue
        static let nextButtonInactive = Color.gray
        static let buttonText = Color.white

        static let secondaryText = Color.secondary

        // Quiz Result View
        static let progressBarBackground = Color.green.opacity(0.25)
        static let progressBarFill = Color.green
        static let resultCardBackground = Color(.systemGray6)
        static let retryButtonBackground = Color.blue.opacity(0.15)
        static let retryButtonText = Color.blue
        static let shareButtonBackground = Color.black.opacity(0.1)
        static let shareButtonText = Color.primary
    }

    // MARK: - Explore Tab Colors
    struct Explore {
        static let icon = Color.orange
        static let secondaryText = Color.secondary
    }

    // MARK: - Widget Colors
    struct Widget {
        // Prayer Widget Colors
        static let prayerBackgroundStart = Color.green
        static let prayerBackgroundEnd = Color.green.opacity(0.7)
        static let prayerPrimaryText = Color.white
        static let prayerSecondaryText = Color.white.opacity(0.8)
        static let prayerTertiaryText = Color.white.opacity(0.7)
        static let prayerDivider = Color.white.opacity(0.3)
        static let prayerCheckmark = Color.green

        // Verse Widget Colors
        static let verseBackgroundStart = Color(red: 0.2, green: 0.4, blue: 0.3)
        static let verseBackgroundEnd = Color(red: 0.15, green: 0.35, blue: 0.25)
        static let versePrimaryText = Color.white
        static let verseSecondaryText = Color.white.opacity(0.9)
        static let verseTertiaryText = Color.white.opacity(0.7)
        static let verseDivider = Color.white.opacity(0.3)
    }

    // MARK: - Common Colors (used across multiple views)
    struct Common {
        static let primary = Color.primary
        static let secondary = Color.secondary

        static let white = Color.white
        static let black = Color.black

        static let systemBackground = Color(.systemBackground)
        static let systemGray5 = Color(.systemGray5)
        static let systemGray6 = Color(.systemGray6)

        static let green = Color.green
        static let blue = Color.blue
        static let orange = Color.orange
        static let gray = Color.gray

        // Material
        static let thinMaterial = Material.thinMaterial
    }
}

// MARK: - Convenience Extensions
extension Color {
    // Helper to access app colors more easily
    static let appColors = AppColors.self
}
