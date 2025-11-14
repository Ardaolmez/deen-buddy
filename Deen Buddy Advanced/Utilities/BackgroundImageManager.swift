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

    // All available background images from BgImages directory
    private let allBackgroundImages = [
        "Al Aqsa Mosque_ Majestic Art.jpg",
        "Alaqsa Mosque_ Majestic Islamic Art.jpg",
        "Awe-Inspiring Al-Aqsa Mosque_ Arabic Art Masterpiece.jpg",
        "Blue Mosque_ Captivating Arabic Art.jpg",
        "Golden Arabic Mornin_ Beauty.jpg",
        "Intricate Arabic Masterpiece.jpg",
        "Majestic Beauty_ Reimagined Mosques.jpg",
        "Moroccan Tapestry _ Vibrant Art.jpg",
        "Pin Islamic mosque Forest mosque location Mosque….jpg",
        "Quba mosque painting.jpg",
        "Suleymaniye Mosque_ Majestic Arabic Art.jpg",
        "Watercolor, Oil Painting & AI-Generated Islamic Art _ Unique Home Decor.jpg",
        "tile.jpg",
        "bg-download.jpg",
        "bg-download-1.jpg",
        "download (2).jpg",
        "download (3).jpg",
        "download (4).jpg",
        "download (11).jpg",
        "f70463413e5dbcd16f08057199702ed3.jpg",
        "fad28ce105d83d22e670b25e03a5aff1.jpg"
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
        allBackgroundImages.randomElement() ?? "tile.jpg"
    }

    /// Get all available background images
    var availableImages: [String] {
        allBackgroundImages
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
