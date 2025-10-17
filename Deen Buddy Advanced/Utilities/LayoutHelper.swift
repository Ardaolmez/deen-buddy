//
//  LayoutHelper.swift
//  Deen Buddy Advanced
//
//  Helper for handling RTL (Right-to-Left) layout support
//  for Arabic, Urdu, and other RTL languages
//

import SwiftUI

struct LayoutHelper {
    /// Returns the appropriate layout direction based on current language
    static var currentDirection: LayoutDirection {
        AppLanguageManager.shared.currentLanguage.isRTL ? .rightToLeft : .leftToRight
    }
}

// Extension to easily apply layout direction to any view
extension View {
    /// Applies the appropriate layout direction based on current app language
    /// Usage: MyView().applyAppLayoutDirection()
    func applyAppLayoutDirection() -> some View {
        self.environment(\.layoutDirection, LayoutHelper.currentDirection)
    }
}
