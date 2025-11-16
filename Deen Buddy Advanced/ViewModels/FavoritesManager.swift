//
//  FavoritesManager.swift
//  Deen Buddy Advanced
//
//  Manager for handling favorite verses with persistence
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published private(set) var favorites: [FavoriteVerse] = []

    private let userDefaultsKey = "SavedFavoriteVerses"

    private init() {
        loadFavorites()
    }

    // MARK: - Public Methods

    /// Add a verse to favorites
    func addFavorite(surahId: Int, verseId: Int) {
        // Check if already favorited
        guard !isFavorite(surahId: surahId, verseId: verseId) else {
            return
        }

        let favorite = FavoriteVerse(surahId: surahId, verseId: verseId)
        favorites.append(favorite)
        saveFavorites()
    }

    /// Remove a verse from favorites
    func removeFavorite(surahId: Int, verseId: Int) {
        favorites.removeAll { $0.surahId == surahId && $0.verseId == verseId }
        saveFavorites()
    }

    /// Remove a favorite by ID
    func removeFavorite(withId id: UUID) {
        favorites.removeAll { $0.id == id }
        saveFavorites()
    }

    /// Toggle favorite status for a verse
    func toggleFavorite(surahId: Int, verseId: Int) {
        if isFavorite(surahId: surahId, verseId: verseId) {
            removeFavorite(surahId: surahId, verseId: verseId)
        } else {
            addFavorite(surahId: surahId, verseId: verseId)
        }
    }

    /// Check if a verse is favorited
    func isFavorite(surahId: Int, verseId: Int) -> Bool {
        return favorites.contains { $0.surahId == surahId && $0.verseId == verseId }
    }

    /// Get all favorites sorted by most recent first
    func getFavorites() -> [FavoriteVerse] {
        return favorites.sorted { $0.timestamp > $1.timestamp }
    }

    /// Get favorites count
    var count: Int {
        return favorites.count
    }

    /// Clear all favorites
    func clearAllFavorites() {
        favorites.removeAll()
        saveFavorites()
    }

    // MARK: - Persistence

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([FavoriteVerse].self, from: data) else {
            favorites = []
            return
        }
        favorites = decoded
    }
}
