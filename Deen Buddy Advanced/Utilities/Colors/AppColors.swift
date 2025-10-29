//
//  AppColors.swift
//  Deen Buddy Advanced
//
//  Base color structure for the entire app
//  Feature-specific colors are defined in separate files
//

import SwiftUI

struct AppColors {

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
