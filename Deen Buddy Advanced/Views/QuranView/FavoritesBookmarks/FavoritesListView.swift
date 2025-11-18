//
//  FavoritesListView.swift
//  Deen Buddy Advanced
//
//  View displaying list of favorite verses
//

import SwiftUI

struct FavoritesListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var quranViewModel = QuranViewModel()

    @State private var searchText = ""
    @State private var selectedVerse: VerseSelection?

    // Identifiable wrapper for verse selection
    struct VerseSelection: Identifiable {
        let id = UUID()
        let surahName: String
        let verseNumber: Int
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                if favoritesManager.favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesList
                }
            }
            .navigationTitle(AppStrings.quran.favorites)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quran.done) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedVerse) { selected in
                VersePopupView(
                    surahName: selected.surahName,
                    verseNumber: selected.verseNumber
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(AppStrings.quran.noFavoritesYet)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text(AppStrings.quran.tapHeartToAddFavorites)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Favorites List

    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredFavorites) { favorite in
                    if let surah = getSurah(id: favorite.surahId),
                       let verse = getVerse(surahId: favorite.surahId, verseId: favorite.verseId) {
                        FavoriteVerseRow(
                            surah: surah,
                            verseId: favorite.verseId,
                            verseText: verse.text,
                            verseTranslation: verse.translation,
                            onDelete: {
                                favoritesManager.removeFavorite(withId: favorite.id)
                            },
                            onTap: {
                                selectedVerse = VerseSelection(
                                    surahName: surah.transliteration,
                                    verseNumber: favorite.verseId
                                )
                            }
                        )

                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search favorites...")
    }

    // MARK: - Filtered Results

    private var filteredFavorites: [FavoriteVerse] {
        let favorites = favoritesManager.getFavorites()

        if searchText.isEmpty {
            return favorites
        }

        return favorites.filter { favorite in
            // Search by verse reference (e.g., "1:1")
            if favorite.verseReference.contains(searchText) {
                return true
            }

            // Search by surah name
            if let surah = getSurah(id: favorite.surahId) {
                if surah.transliteration.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                if let translation = surah.translation,
                   translation.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }

            return false
        }
    }

    // MARK: - Helper Methods

    private func getSurah(id: Int) -> Surah? {
        return quranViewModel.surahs.first { $0.id == id }
    }

    private func getVerse(surahId: Int, verseId: Int) -> Verse? {
        guard let surah = getSurah(id: surahId),
              verseId > 0 && verseId <= surah.verses.count else {
            return nil
        }
        return surah.verses[verseId - 1]
    }
}

// MARK: - Favorite Verse Row

struct FavoriteVerseRow: View {
    let surah: Surah
    let verseId: Int
    let verseText: String
    let verseTranslation: String?
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Verse reference circle
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.prayerGreen.opacity(0.1))
                    .frame(width: 44, height: 44)

                VStack(spacing: 2) {
                    Text("\(surah.id)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.Prayers.prayerGreen)

                    Text("\(verseId)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                }
            }

            // Verse content
            VStack(alignment: .leading, spacing: 8) {
                // Surah name - Transliteration and English
                HStack(spacing: 8) {
                    Text(surah.transliteration)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    if let translation = surah.translation {
                        Text("•")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)

                        Text(translation)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }

                // Arabic text (preview)
                Text(verseText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Translation (preview)
                if let translation = verseTranslation {
                    Text(translation)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.Prayers.prayerGreen)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    FavoritesListView()
}
