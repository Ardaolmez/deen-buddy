//
//  ChatColors.swift
//  Deen Buddy Advanced
//
//  Color definitions for the Chat feature
//

import SwiftUI

extension AppColors {

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
}
