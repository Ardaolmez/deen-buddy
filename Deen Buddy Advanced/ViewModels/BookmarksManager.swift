//
//  BookmarksManager.swift
//  Deen Buddy Advanced
//
//  Manager for handling bookmark folders with persistence
//

import Foundation
import Combine

class BookmarksManager: ObservableObject {
    static let shared = BookmarksManager()

    @Published private(set) var folders: [BookmarkFolder] = []

    private let userDefaultsKey = "SavedBookmarkFolders"

    private init() {
        loadFolders()
    }

    // MARK: - Folder Management

    /// Create a new bookmark folder
    func createFolder(name: String) {
        let folder = BookmarkFolder(name: name)
        folders.append(folder)
        saveFolders()
    }

    /// Delete a folder by ID
    func deleteFolder(withId id: UUID) {
        folders.removeAll { $0.id == id }
        saveFolders()
    }

    /// Rename a folder
    func renameFolder(withId id: UUID, newName: String) {
        if let index = folders.firstIndex(where: { $0.id == id }) {
            folders[index].name = newName
            folders[index].updatedAt = Date()
            saveFolders()
        }
    }

    /// Get folder by ID
    func getFolder(withId id: UUID) -> BookmarkFolder? {
        return folders.first { $0.id == id }
    }

    /// Get all folders sorted by creation date
    func getFolders() -> [BookmarkFolder] {
        return folders.sorted { $0.createdAt > $1.createdAt }
    }

    /// Get total number of folders
    var folderCount: Int {
        return folders.count
    }

    // MARK: - Verse Management

    /// Add a verse to a specific folder
    func addVerseToFolder(folderId: UUID, surahId: Int, verseId: Int) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            // Check if verse already exists in this folder
            if !folders[index].containsVerse(surahId: surahId, verseId: verseId) {
                folders[index].addVerse(surahId: surahId, verseId: verseId)
                saveFolders()
            }
        }
    }

    /// Remove a verse from a specific folder
    func removeVerseFromFolder(folderId: UUID, verseId: UUID) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            folders[index].removeVerse(withId: verseId)
            saveFolders()
        }
    }

    /// Remove a verse from a folder by surah and verse ID
    func removeVerseFromFolder(folderId: UUID, surahId: Int, verseId: Int) {
        if let index = folders.firstIndex(where: { $0.id == folderId }),
           let verseToRemove = folders[index].verses.first(where: {
               $0.surahId == surahId && $0.verseId == verseId
           }) {
            folders[index].removeVerse(withId: verseToRemove.id)
            saveFolders()
        }
    }

    /// Check if a verse exists in a specific folder
    func isVerseInFolder(folderId: UUID, surahId: Int, verseId: Int) -> Bool {
        guard let folder = folders.first(where: { $0.id == folderId }) else {
            return false
        }
        return folder.containsVerse(surahId: surahId, verseId: verseId)
    }

    /// Check if a verse exists in any folder
    func isVerseBookmarked(surahId: Int, verseId: Int) -> Bool {
        return folders.contains { folder in
            folder.containsVerse(surahId: surahId, verseId: verseId)
        }
    }

    /// Get all folders containing a specific verse
    func getFoldersContainingVerse(surahId: Int, verseId: Int) -> [BookmarkFolder] {
        return folders.filter { folder in
            folder.containsVerse(surahId: surahId, verseId: verseId)
        }
    }

    /// Get total count of all bookmarked verses across all folders
    var totalBookmarkedVerses: Int {
        return folders.reduce(0) { $0 + $1.verseCount }
    }

    // MARK: - Bulk Operations

    /// Clear all folders
    func clearAllFolders() {
        folders.removeAll()
        saveFolders()
    }

    /// Delete empty folders
    func deleteEmptyFolders() {
        folders.removeAll { $0.isEmpty }
        saveFolders()
    }

    // MARK: - Persistence

    private func saveFolders() {
        if let encoded = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadFolders() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([BookmarkFolder].self, from: data) else {
            folders = []
            return
        }
        folders = decoded
    }
}
