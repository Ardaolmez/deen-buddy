//
//  BackgroundImageManager.swift
//  Deen Buddy Advanced
//
//  Manages random background image selection for cards
//

import Foundation
import SwiftUI

/// Manages background images for cards with stable daily rotation
final class BackgroundImageManager {
    static let shared = BackgroundImageManager()

    // All available background images from Asset Catalog
    private let allBackgroundImages = [
        "bg_alaqsa_1",
        "bg_alaqsa_2",
        "bg_alaqsa_3",
        "bg_blue_mosque",
        "bg_golden_arabic",
        "bg_intricate_arabic",
        "bg_majestic_mosques",
        "bg_moroccan",
        "bg_forest_mosque",
        "bg_quba_mosque",
        "bg_suleymaniye",
        "bg_watercolor_art",
        "bg_tile",
        "bg_download_1",
        "bg_download_2",
        "bg_misc_1",
        "bg_misc_2",
        "bg_misc_3",
        "bg_misc_4",
        "bg_misc_5",
        "bg_misc_6"
    ]

    // All available tile pattern images from Asset Catalog
    private let allTilePatterns = [
        "tile_carpet",
        "tile_pattern_1",
        "tile_pattern_2",
        "tile_pattern_3",
        "tile_pattern_4",
        "tile_pattern_5",
        "tile_pattern_6",
        "tile_pattern_7",
        "tile_pattern_8",
        "tile_tezhib",
        "tile_minakari",
        "tile_nasir_mosque",
        "tile_decorative"
    ]

    // Cache for daily selected images
    private var dailyImageCache: [String: String] = [:]
    private let lastDateKey = "lastBackgroundImageDate"

    private init() {
        // Clear cache if it's a new day
        checkAndResetCacheIfNeeded()
    }

    /// Get a random background image for a specific card type
    /// Images are stable for the same card type on the same day
    /// - Parameter cardType: Identifier for the card type (e.g., "verse", "durood", "readingGoal")
    /// - Returns: Image name from the background images array
    func getRandomImage(for cardType: String) -> String {
        // Check cache first
        if let cached = dailyImageCache[cardType] {
            return cached
        }

        // Generate a stable random image for this card type today
        let today = getCurrentDateString()
        let seed = seedValue(from: today + cardType)
        let index = abs(seed) % allBackgroundImages.count
        let selectedImage = allBackgroundImages[index]

        // Cache it
        dailyImageCache[cardType] = selectedImage

        return selectedImage
    }

    /// Get a truly random image (changes on each call)
    /// - Returns: Random image name
    func getTrulyRandomImage() -> String {
        allBackgroundImages.randomElement() ?? "bg_tile"
    }

    /// Get all available background images
    var availableImages: [String] {
        allBackgroundImages
    }

    /// Get all available tile patterns
    var availableTilePatterns: [String] {
        allTilePatterns
    }

    /// Get a random tile pattern (changes on each call)
    func getRandomTilePattern() -> String {
        allTilePatterns.randomElement() ?? "tile_pattern_1"
    }

    /// Get a stable tile pattern for a specific card type
    func getTilePattern(for cardType: String) -> String {
        let cacheKey = "tile_\(cardType)"
        if let cached = dailyImageCache[cacheKey] {
            return cached
        }

        let today = getCurrentDateString()
        let seed = seedValue(from: today + cacheKey)
        let index = abs(seed) % allTilePatterns.count
        let selectedPattern = allTilePatterns[index]

        dailyImageCache[cacheKey] = selectedPattern
        return selectedPattern
    }

    // MARK: - Private Helpers

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    private func checkAndResetCacheIfNeeded() {
        let today = getCurrentDateString()
        let lastDate = UserDefaults.standard.string(forKey: lastDateKey)

        if lastDate != today {
            // New day - clear cache
            dailyImageCache.removeAll()
            UserDefaults.standard.set(today, forKey: lastDateKey)
        }
    }

    /// Generate a stable seed value from a string
    private func seedValue(from string: String) -> Int {
        var hash = 0
        for char in string.unicodeScalars {
            hash = 31 &* hash &+ Int(char.value)
        }
        return hash
    }
}

// MARK: - Convenience Extension

extension BackgroundImageManager {
    /// Predefined card types for consistency
    enum CardType {
        case verse
        case durood
        case dua
        case wisdom
        case readingGoal
        case dailyVerse

        var identifier: String {
            switch self {
            case .verse: return "verse"
            case .durood: return "durood"
            case .dua: return "dua"
            case .wisdom: return "wisdom"
            case .readingGoal: return "readingGoal"
            case .dailyVerse: return "dailyVerse"
            }
        }
    }

    /// Get random image using CardType enum
    func getRandomImage(for cardType: CardType) -> String {
        getRandomImage(for: cardType.identifier)
    }
}

// MARK: - Preloading

extension BackgroundImageManager {
    /// Preload essential launch images into memory
    func preloadLaunchImages() {
        // Preload first few background images for quick access
        let launchImages = Array(allBackgroundImages.prefix(5))
        for imageName in launchImages {
            _ = UIImage(named: imageName)
        }
    }

    /// Preload daily card images based on today's selections
    func preloadDailyCardImages() {
        // Preload images that will be used for today's cards
        let cardTypes: [CardType] = [.verse, .durood, .dua, .wisdom, .readingGoal, .dailyVerse]
        for cardType in cardTypes {
            let imageName = getRandomImage(for: cardType)
            _ = UIImage(named: imageName)
        }
    }
}
