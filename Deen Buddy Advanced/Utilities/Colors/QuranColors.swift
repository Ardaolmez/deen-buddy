//
//  QuranColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Quran tab
//

import SwiftUI

extension AppColors {

    // MARK: - Quran Tab Colors
    struct Quran {
        // Background Gradients
        static let backgroundGradientStart = Color(red: 0.98, green: 0.94, blue: 0.82)
        static let backgroundGradientEnd = Color(red: 0.96, green: 0.92, blue: 0.78)

        // Page Background (Radial Gradient) - Cream/Parchment Theme
        static let pageCenter = Color.white
        static let pageRing1 = Color(red: 0.998, green: 0.99, blue: 0.98)
        static let pageRing2 = Color(red: 0.995, green: 0.985, blue: 0.96)
        static let pageRing3 = Color(red: 0.99, green: 0.98, blue: 0.94)
        static let pageRing4 = Color(red: 0.985, green: 0.97, blue: 0.90)

        // Page Background (Radial Gradient) - Ottoman Blue Theme (Alternative)
        // Base: #4f97a3 (Ottoman Blue)
        static let pageCenterBlue = Color.white
        static let pageRing1Blue = Color(red: 0.96, green: 0.98, blue: 0.99) // #f5fafb - Very pale blue
        static let pageRing2Blue = Color(red: 0.93, green: 0.97, blue: 0.98) // #edf7f9 - Pale blue
        static let pageRing3Blue = Color(red: 0.88, green: 0.94, blue: 0.96) // #e0f0f5 - Light blue
        static let pageRing4Blue = Color(red: 0.83, green: 0.91, blue: 0.93) // #d4e8ed - Soft blue

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
}
