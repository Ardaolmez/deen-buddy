//
//  ExploreColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Explore tab
//

import SwiftUI

extension AppColors {

    // MARK: - Explore Tab Colors
    struct Explore {
        // Primary accent - Classic app green
        static let accent = Color.green
        static let accentLight = Color.green.opacity(0.15)

        // Card backgrounds
        static let cardBackground = Color(.systemGray6)
        static let cardBackgroundHighlighted = Color(.systemBackground)

        // Icon and emphasis colors
        static let iconBackground = Color.green.opacity(0.15)
        static let iconForeground = Color.green

        // Text colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let accentText = Color.green
        static let hijriCardPrimaryText = Color.primary
        static let hijriCardSecondaryText = Color.secondary
        static let hijriCardAccent = Color(red: 0.29, green: 0.55, blue: 0.42)

        // State colors
        static let available = Color.green
        static let locked = Color.secondary
        static let completed = Color.green
        static let comingSoon = Color.secondary.opacity(0.6)

        // Shadows and borders
        static let cardShadow = Color.black.opacity(0.05)
        static let subtleBorder = Color.black.opacity(0.05)

        // Subtle backgrounds for emphasis
        static let subtleAccent = Color.green.opacity(0.08)
        static let subtleGray = Color(.systemGray6)
        static let hijriCardBackground = Color(.systemBackground)
        static let hijriCardBorder = Color.black.opacity(0.05)

        // Progress indicators
        static let progressFill = Color.green
        static let progressBackground = Color(.systemGray5)
    }
}
