//
//  WidgetColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for Widgets
//

import SwiftUI

extension AppColors {

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
}
