//
//  PrayersColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Prayers tab
//

import SwiftUI

extension AppColors {

    // MARK: - Prayers Tab Colors
    struct Prayers {
        // Minimal Design Colors
        static let prayerGreen = Color(red: 0.29, green: 0.55, blue: 0.42)
        static let prayerBlue = Color.blue
        static let prayerOrange = Color.orange

        // Time-of-day colors for prayer icons
        static let fajrColor =  Color.primary
        static let dhuhrColor = Color.primary
        static let asrColor =  Color.primary
        static let maghribColor =  Color.primary
        static let ishaColor = Color.primary

        // Subtle backgrounds
        static let subtleGreen = Color.green.opacity(0.08)
        static let subtleBlue = Color.blue.opacity(0.08)
        static let subtleGray = Color(.systemGray6)

        // Shadow colors
        static let greenShadow = Color.green.opacity(0.2)
        static let blueShadow = Color.blue.opacity(0.2)
        static let lightShadow = Color.black.opacity(0.05)

        // Legacy colors (kept for compatibility)
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

        // ===== Stats / Heatmap =====
               /// Filled cells
        // Jumu'ah (Friday Dhuhr) — DARK GREEN
                static let heatmapJamaah = Color(hue: 0.34, saturation: 0.75, brightness: 0.55) // #2F8F4E-ish

                // On time — LIGHT GREEN
                static let heatmapOnTime = Color(hue: 0.35, saturation: 0.35, brightness: 0.92) // #CFEBD8-ish

                // Late / Missed (unchanged)
                static let heatmapLate   = Color(hue: 0.98, saturation: 0.80, brightness: 0.85) // red
                static let heatmapMissed = Color.black.opacity(0.85)                             // near-black


               /// Empty / no data cell
               static let heatmapEmpty  = Color.gray.opacity(0.25)

               /// Heatmap container background
               static let statsHeatmapBackground = Color(.systemGray6)

               /// Range selector (Weeks / Months / Years / All time)
               static let segmentSelected       = Color.green.opacity(0.18)
               static let segmentBackground     = Color(.systemGray5)
               static let segmentTextSelected   = Color.green

               /// Summary cards background
               static let summaryCardBackground = Color(.systemGray6)
    }
}
