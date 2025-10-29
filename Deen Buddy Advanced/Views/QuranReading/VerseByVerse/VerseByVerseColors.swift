//
//  VerseByVerseColors.swift
//  Deen Buddy Advanced
//
//  Color palette for verse-by-verse reading with white background and green accents
//

import SwiftUI

extension AppColors {

    // MARK: - Verse By Verse Reading Colors
    struct VerseByVerse {

        // MARK: - Light Background (White)
        static let background = Color.white
        static let backgroundGradient = LinearGradient(
            gradient: Gradient(colors: [Color.white]),
            startPoint: .top,
            endPoint: .bottom
        )

        // MARK: - Accent Colors (Green from ChatView)
        static let accentGreen = Color(red: 0.29, green: 0.55, blue: 0.42)   // Primary green
        static let accentGold = Color(red: 0.29, green: 0.55, blue: 0.42)    // Use green instead of gold
        static let accentPurple = Color(red: 0.6, green: 0.3, blue: 0.8)     // Purple
        static let accentTeal = Color(red: 0.2, green: 0.8, blue: 0.8)       // Teal

        // MARK: - Card Backgrounds (Light theme)
        static let cardBackground = Color(.systemGray6)
        static let cardElevated = Color.white
        static let cardHighlight = Color(.systemGray5)

        // Metrics card gradient (subtle light)
        static let metricsCardGradient = LinearGradient(
            gradient: Gradient(colors: [Color.white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Text Colors
        static let textPrimary = Color.black
        static let textSecondary = Color.black.opacity(0.7)
        static let textTertiary = Color.black.opacity(0.5)
        static let textAccent = accentGreen

        // MARK: - Arabic Text (ChatView dark mode gradient)
        static let arabicText = Color.white
        static let arabicGlow = accentGreen.opacity(0.3)

        // Dark gradient background for Arabic (from ChatColors)
        static let darkBackgroundTop = Color(red: 0.1, green: 0.1, blue: 0.25)
        static let darkBackgroundMid = Color(red: 0.15, green: 0.1, blue: 0.3)
        static let darkBackgroundBottom = Color(red: 0.08, green: 0.08, blue: 0.2)

        static let arabicCardGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: darkBackgroundTop, location: 0.0),
                .init(color: darkBackgroundMid, location: 0.5),
                .init(color: darkBackgroundBottom, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Translation Text (ChatView light mode gradient)
        static let translationText = Color.black

        // Light gradient background for translation (ChatView light mode)
        static let lightBackgroundStart = Color.white
        static let lightBackgroundEnd = Color(.systemGray6)

        static let translationCardGradient = LinearGradient(
            gradient: Gradient(colors: [lightBackgroundStart, lightBackgroundEnd]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Metrics Display
        static let metricsLabel = Color.black.opacity(0.6)
        static let metricsValue = accentGreen
        static let metricsIcon = accentGreen
        static let metricsDivider = Color.black.opacity(0.2)

        // MARK: - Progress Indicators
        static let progressBackground = Color(.systemGray5)
        static let progressFill = LinearGradient(
            gradient: Gradient(colors: [accentGreen, accentGreen]),
            startPoint: .leading,
            endPoint: .trailing
        )
        static let progressStreak = accentGreen
        static let progressGoal = accentGreen

        // MARK: - Surah Header
        static let surahName = accentGreen
        static let surahTransliteration = Color.black.opacity(0.7)
        static let bismillah = accentGreen

        // MARK: - Verse Number Badge
        static let verseNumberBackground = cardBackground
        static let verseNumberText = accentGreen
        static let verseNumberBorder = accentGreen.opacity(0.5)

        // MARK: - Shadows & Glows
        static let shadowPrimary = Color.black.opacity(0.1)
        static let shadowSecondary = Color.black.opacity(0.05)
        static let glowGold = accentGreen.opacity(0.2)
        static let glowPurple = accentPurple.opacity(0.1)

        // MARK: - Navigation & Controls
        static let closeButton = accentGreen
        static let closeButtonBackground = Color.white
        static let navigationDot = Color.black.opacity(0.3)
        static let navigationDotActive = accentGreen

        // MARK: - Decorative Elements
        static let ornamentTop = accentGreen.opacity(0.6)
        static let ornamentBottom = accentGreen.opacity(0.6)
        static let dividerLine = Color.black.opacity(0.15)
    }
}
