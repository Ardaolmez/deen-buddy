//
//  QuranStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Quran tab
//

import Foundation

private let table = "Quran"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct QuranStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var loading: String { lang.getString("loading", table: table) }
    static var selectSurah: String { lang.getString("selectSurah", table: table) }
    static var selectLanguage: String { lang.getString("selectLanguage", table: table) }
    static var verses: String { lang.getString("verses", table: table) }
    static var surahCount: String { lang.getString("surahCount", table: table) }
    static var errorMessage: String { lang.getString("errorMessage", table: table) }
    static var retry: String { lang.getString("retry", table: table) }
    static var done: String { lang.getString("done", table: table) }

    // Surah Selector
    static var searchSurahPlaceholder: String { lang.getString("searchSurahPlaceholder", table: table) }
    static var versesCount: String { lang.getString("versesCount", table: table) }
    static var surahType: String { lang.getString("surahType", table: table) }

    // Error Messages
    static var couldNotLoadQuranData: String { lang.getString("couldNotLoadQuranData", table: table) }

    // Sample Text for Settings (not localized - Arabic stays Arabic)
    static let sampleBismillah = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
    static var sampleBismillahTranslation: String { lang.getString("sampleBismillahTranslation", table: table) }

    // Metrics Card
    static var metricTime: String { lang.getString("metricTime", table: table) }
    static var metricGoal: String { lang.getString("metricGoal", table: table) }
    static var metricStreak: String { lang.getString("metricStreak", table: table) }
    static var metricGoalFormat: String { lang.getString("metricGoalFormat", table: table) }

    // Main Page
    static var startReading: String { lang.getString("startReading", table: table) }
    static var continueReading: String { lang.getString("continueReading", table: table) }
    static var beginYourJourney: String { lang.getString("beginYourJourney", table: table) }
    static var lastRead: String { lang.getString("lastRead", table: table) }
    static var surahBysurah: String { lang.getString("surahBysurah", table: table) }
    static var juzByJuz: String { lang.getString("juzByJuz", table: table) }
    static var surahs: String { lang.getString("surahs", table: table) }
    static var juz: String { lang.getString("juz", table: table) }
    static var juzCount: String { lang.getString("juzCount", table: table) }
    static var totalJuz: String { lang.getString("totalJuz", table: table) }
    static var browseAllSurahs: String { lang.getString("browseAllSurahs", table: table) }
    static var browseAllJuz: String { lang.getString("browseAllJuz", table: table) }
    static var tapToSelect: String { lang.getString("tapToSelect", table: table) }
    static var verses30Juz: String { lang.getString("verses30Juz", table: table) }

    // Favorites & Bookmarks
    static var favorites: String { lang.getString("favorites", table: table) }
    static var bookmarks: String { lang.getString("bookmarks", table: table) }
    static var noFavoritesYet: String { lang.getString("noFavoritesYet", table: table) }
    static var tapHeartToAddFavorites: String { lang.getString("tapHeartToAddFavorites", table: table) }
    static var noBookmarksYet: String { lang.getString("noBookmarksYet", table: table) }
    static var createFolderToOrganize: String { lang.getString("createFolderToOrganize", table: table) }
    static var addNewFolder: String { lang.getString("addNewFolder", table: table) }
    static var folderName: String { lang.getString("folderName", table: table) }
    static var create: String { lang.getString("create", table: table) }
    static var cancel: String { lang.getString("cancel", table: table) }
    static var enterFolderName: String { lang.getString("enterFolderName", table: table) }
    static var rename: String { lang.getString("rename", table: table) }
    static var delete: String { lang.getString("delete", table: table) }
    static var selectFolder: String { lang.getString("selectFolder", table: table) }
    static var addToBookmark: String { lang.getString("addToBookmark", table: table) }
    static var verse: String { lang.getString("verse", table: table) }
    static var noVersesInFolder: String { lang.getString("noVersesInFolder", table: table) }
    static var addVersesWhileReading: String { lang.getString("addVersesWhileReading", table: table) }
    static var folders: String { lang.getString("folders", table: table) }
    static var verseInFolder: String { lang.getString("verseInFolder", table: table) }
    static var versesInFolder: String { lang.getString("versesInFolder", table: table) }
    static var deleteFolderConfirmation: String { lang.getString("deleteFolderConfirmation", table: table) }
    static var deleteConfirm: String { lang.getString("deleteConfirm", table: table) }
    static var back: String { lang.getString("back", table: table) }
    static var searchFolders: String { lang.getString("searchFolders", table: table) }
    static var searchVerses: String { lang.getString("searchVerses", table: table) }
    static var searchFavorites: String { lang.getString("searchFavorites", table: table) }
}
