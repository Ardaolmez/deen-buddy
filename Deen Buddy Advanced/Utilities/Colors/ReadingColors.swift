//
//  ReadingColors.swift
//  Deen Buddy Advanced
//
//  Enhanced color definitions for the Quran Reading feature with new palette
//

import SwiftUI

extension AppColors {

    // MARK: - Reading View Colors
    struct Reading {
        // MARK: - Dark Color Palette
        static let darkBackgroundTop = Color(red: 0.1, green: 0.1, blue: 0.25)
        static let darkBackgroundMid = Color(red: 0.15, green: 0.1, blue: 0.3)
        static let darkBackgroundBottom = Color(red: 0.08, green: 0.08, blue: 0.2)

        // MARK: - Light Color Palette
        static let pageCenter = Color.white
        static let pageRing1 = Color(red: 0.998, green: 0.99, blue: 0.98)
        static let pageRing2 = Color(red: 0.995, green: 0.985, blue: 0.96)
        static let pageRing3 = Color(red: 0.99, green: 0.98, blue: 0.94)
        static let pageRing4 = Color(red: 0.985, green: 0.97, blue: 0.90)

        // MARK: - Background Gradients
        static let background = pageCenter

        // Enhanced header background with new palette
        static let headerBackground = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: pageCenter, location: 0.0),
                .init(color: pageRing1, location: 0.25),
                .init(color: pageRing2, location: 0.5),
                .init(color: pageRing3, location: 0.75),
                .init(color: pageRing4, location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )

        // Dark gradient for contrast elements
        static let darkGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: darkBackgroundTop, location: 0.0),
                .init(color: darkBackgroundMid, location: 0.5),
                .init(color: darkBackgroundBottom, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Header Colors
        static let headerTimer = darkBackgroundTop
        static let headerGoal = darkBackgroundMid
        static let headerPosition = darkBackgroundBottom
        static let closeButton = darkBackgroundTop

        // MARK: - Progress System Colors
        static let progressBackground = pageRing3
        static let progressFill = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.29, green: 0.55, blue: 0.42),
                Color(red: 0.35, green: 0.65, blue: 0.52)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )

        // Multi-dimensional progress ring colors
        static let progressRingBackground = pageRing2
        static let progressRingGoal = Color(red: 0.29, green: 0.55, blue: 0.42)
        static let progressRingVerses = Color(red: 0.2, green: 0.4, blue: 0.8)
        static let progressRingTime = Color(red: 0.6, green: 0.3, blue: 0.8)
        static let progressRingStreak = Color(red: 0.9, green: 0.5, blue: 0.1)

        // MARK: - Page Content Colors
        static let pageCardBackground = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: pageCenter, location: 0.0),
                .init(color: pageRing1, location: 0.3),
                .init(color: pageRing2, location: 0.6),
                .init(color: pageRing3, location: 0.8),
                .init(color: pageRing4, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - Text Colors
        static let verseNumber = darkBackgroundMid
        static let verseText = darkBackgroundBottom
        static let verseDivider = pageRing3
        static let verseHighlight = Color(red: 0.29, green: 0.55, blue: 0.42).opacity(0.1)

        // MARK: - Surah Header Colors
        static let surahName = darkBackgroundTop
        static let surahTransliteration = darkBackgroundMid
        static let surahDivider = Color(red: 0.29, green: 0.55, blue: 0.42).opacity(0.3)

        // MARK: - Reading Metrics Colors
        static let metricsBackground = pageRing1
        static let metricsText = darkBackgroundBottom
        static let metricsAccent = Color(red: 0.29, green: 0.55, blue: 0.42)
        static let metricsSecondary = darkBackgroundMid

        // MARK: - Achievement Colors
        static let achievementGold = Color(red: 0.9, green: 0.7, blue: 0.1)
        static let achievementSilver = Color(red: 0.7, green: 0.7, blue: 0.7)
        static let achievementBronze = Color(red: 0.8, green: 0.5, blue: 0.2)

        // MARK: - Animation Colors
        static let animationPrimary = Color(red: 0.29, green: 0.55, blue: 0.42)
        static let animationSecondary = darkBackgroundMid
        static let animationAccent = Color(red: 0.6, green: 0.3, blue: 0.8)
    }
}
