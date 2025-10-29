//
//  QuranFontSizeManager.swift
//  Deen Buddy Advanced
//
//  Manages font size preferences for Quran reading
//

import Foundation
import SwiftUI
import Combine

// Singleton to manage Quran font size settings
class QuranFontSizeManager: ObservableObject {
    static let shared = QuranFontSizeManager()

    @Published var fontSizeMultiplier: CGFloat {
        didSet {
            saveFontSizePreference()
        }
    }

    // Predefined font size options
    enum FontSize: CaseIterable {
        case extraSmall
        case small
        case medium
        case large
        case extraLarge

        var multiplier: CGFloat {
            switch self {
            case .extraSmall: return 0.75
            case .small: return 0.85
            case .medium: return 1.0
            case .large: return 1.15
            case .extraLarge: return 1.3
            }
        }

        var displayName: String {
            switch self {
            case .extraSmall: return "Extra Small"
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            case .extraLarge: return "Extra Large"
            }
        }
    }

    @Published var currentFontSize: FontSize = .medium {
        didSet {
            fontSizeMultiplier = currentFontSize.multiplier
        }
    }

    private let userDefaultsKey = "quranFontSizeMultiplier"
    private let fontSizeIndexKey = "quranFontSizeIndex"

    // Min and max limits for the multiplier
    let minMultiplier: CGFloat = 0.7
    let maxMultiplier: CGFloat = 1.5

    private init() {
        // Load saved font size or default to medium
        if let savedMultiplier = UserDefaults.standard.object(forKey: userDefaultsKey) as? CGFloat {
            self.fontSizeMultiplier = min(max(savedMultiplier, minMultiplier), maxMultiplier)

            // Find the closest preset
            self.currentFontSize = FontSize.allCases.min(by: {
                abs($0.multiplier - savedMultiplier) < abs($1.multiplier - savedMultiplier)
            }) ?? .medium
        } else {
            self.fontSizeMultiplier = 1.0
            self.currentFontSize = .medium
        }
    }

    private func saveFontSizePreference() {
        UserDefaults.standard.set(fontSizeMultiplier, forKey: userDefaultsKey)
    }

    // Convenience methods for adjusting font size
    func increaseFontSize() {
        let newMultiplier = min(fontSizeMultiplier + 0.1, maxMultiplier)
        fontSizeMultiplier = newMultiplier
        updateCurrentFontSize()
    }

    func decreaseFontSize() {
        let newMultiplier = max(fontSizeMultiplier - 0.1, minMultiplier)
        fontSizeMultiplier = newMultiplier
        updateCurrentFontSize()
    }

    func resetToDefault() {
        currentFontSize = .medium
        fontSizeMultiplier = 1.0
    }

    private func updateCurrentFontSize() {
        // Find the closest preset to current multiplier
        currentFontSize = FontSize.allCases.min(by: {
            abs($0.multiplier - fontSizeMultiplier) < abs($1.multiplier - fontSizeMultiplier)
        }) ?? .medium
    }

    // Apply multiplier to a font size
    func scaledFontSize(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * fontSizeMultiplier
    }
}