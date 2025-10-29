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

        // Papyrus Colors (for other views)
        static let papyrusSquare = Color(red: 0.99, green: 0.98, blue: 0.94)  // Same as pageRing3
        static let papyrusLight = Color(red: 0.995, green: 0.99, blue: 0.97)

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

        // Error State
        static let errorIcon = Color.orange
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
        static let verseCardShadow = Color.black.opacity(0.1)
        static let verseCardProgressTint = Color.white
    }

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
        // Jumu’ah (Friday Dhuhr) — DARK GREEN
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
    
    

    // MARK: - Quiz Tab Colors
    struct Quiz {
        static let nextButtonActive = Color.blue
        static let nextButtonInactive = Color.gray
        static let buttonText = Color.white


        // Quiz Result View
        static let progressBarBackground = Color.green.opacity(0.25)
        static let progressBarFill = Color.green
        static let resultCardBackground = Color(.systemGray6)
        static let retryButtonBackground = Color.blue.opacity(0.15)
        static let retryButtonText = Color.blue
        static let shareButtonBackground = Color.black.opacity(0.1)
        static let shareButtonText = Color.primary

        // Answer Row Colors
        static let answerText = Color.primary
        static let answerNeutralBackground = Color(.systemGray6)
        static let answerCorrectBackground = Color.green.opacity(0.15)
        static let answerWrongBackground = Color.red.opacity(0.15)
        static let answerNeutralBorder = Color.clear
        static let answerCorrectBorder = Color.green
        static let answerWrongBorder = Color.red

        // Explanation Card Colors
        static let explanationCardBackground = Color(.systemGray6)
        static let explanationCorrectHeader = Color.green
        static let explanationIncorrectHeader = Color.red
        static let explanationText = Color.primary
        static let explanationReference = Color.secondary

        // Verse Display Colors
        static let verseArabicText = Color.primary
        static let verseTranslationText = Color.secondary
        static let verseCardBackground = Color(.systemBackground)

        // Verse Popup Colors
        static let referenceLink = Color.blue
        static let versePopupHighlight = Color.yellow.opacity(0.2)
        static let versePopupVerseNumber = Color.secondary

        // Progress Ring Colors
        static let progressRingBackground = Color.black.opacity(0.08)
        static let progressRingFill = Color.green
    }

    // MARK: - Explore Tab Colors
    struct Explore {
        static let icon = Color.orange
        static let secondaryText = Color.secondary
    }

    // MARK: - Chat Colors
    struct Chat {
        static let boxIcon = Color.secondary
        static let boxText = Color.secondary
        static let boxBackground = Color(.systemGray6)
        static let boxBorder = Color(.systemGray4)

        // Input field colors
        static func inputBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? .white : Color(.systemGray6)
        }
        static func inputText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? .black : .white
        }
        static func inputPlaceholder(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color.black.opacity(0.5) : Color.white.opacity(0.5)
        }

        // Send button colors
        static func sendButtonIcon(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color(red: 0.985, green: 0.97, blue: 0.90) : Color(red: 0.08, green: 0.08, blue: 0.2)
        }
        static func userText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? .white : .black
        }
        static func sendButtonActive(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color(red: 0.29, green: 0.55, blue: 0.42) : Color(red: 1.0, green: 0.92, blue: 0.3)
        }

        static let sendButtonInactive = Color.gray
        static let containerBackground = Color(.systemBackground)

        // Shadow colors
        static let shadowLight = Color.black.opacity(0.04)
        static let shadowMedium = Color.black.opacity(0.08)
        static let shadowStrong = Color.black.opacity(0.12)

        // Stop button (uses same colors as active send button)
        static func stopButtonBackground(for colorScheme: ColorScheme) -> Color {
            sendButtonActive(for: colorScheme)
        }
        static func stopButtonIcon(for colorScheme: ColorScheme) -> Color {
            sendButtonIcon(for: colorScheme)
        }

        // Citation card (uses same colors as user message bubble)
        static func citationCardBackground(for colorScheme: ColorScheme) -> Color {
            sendButtonActive(for: colorScheme)
        }
        static func citationCardText(for colorScheme: ColorScheme) -> Color {
            userText(for: colorScheme)
        }
        static func citationCardIcon(for colorScheme: ColorScheme) -> Color {
            userText(for: colorScheme)
        }

        // Header colors (adaptive for light/dark mode)
        static func headerTitle(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color(red: 0.29, green: 0.55, blue: 0.42) : Color(red: 1.0, green: 0.92, blue: 0.3) // Green in light, bright yellow in dark
        }

        static func closeButton(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color(red: 0.29, green: 0.55, blue: 0.42) : Color(red: 1.0, green: 0.92, blue: 0.3) // Green in light, bright yellow in dark
        }

        // Background gradient colors (dark mode)
        static let darkBackgroundTop = Color(red: 0.1, green: 0.1, blue: 0.25)
        static let darkBackgroundMid = Color(red: 0.15, green: 0.1, blue: 0.3)
        static let darkBackgroundBottom = Color(red: 0.08, green: 0.08, blue: 0.2)

        // Star colors (dark mode)
        static let starColor = Color.yellow
        static let starGlow = Color.yellow
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

    // MARK: - Feedback Colors
    struct Feedback {
        static let successIcon = Color.green
        static let successText = Color.green
        static let successBackground = Color.green.opacity(0.1)
        static let errorIcon = Color.red
        static let errorText = Color.red
        static let errorBackground = Color.red.opacity(0.1)
    }

    // MARK: - Common Colors (used across multiple views)
    struct Common {
        static let primary = Color.primary
        static let secondary = Color.secondary

        static let white = Color.white
        static let black = Color.black
        static let clear = Color.clear

        static let systemBackground = Color(.systemBackground)
        static let systemGray5 = Color(.systemGray5)
        static let systemGray6 = Color(.systemGray6)

        static let green = Color.green
        static let blue = Color.blue
        static let orange = Color.orange
        static let gray = Color.gray

        // Selection states
        static let checkmarkSelected = Color.green

        // Material
        static let thinMaterial = Material.thinMaterial
    }
}

// MARK: - Convenience Extensions
extension Color {
    // Helper to access app colors more easily
    static let appColors = AppColors.self
}
