//
//  QuranMainView.swift
//  Deen Buddy Advanced
//
//  Main landing page for Quran with navigation options
//

import SwiftUI

struct QuranMainView: View {
    @StateObject private var quranViewModel = QuranViewModel()
    @StateObject private var goalViewModel = ReadingGoalViewModel.shared
    @StateObject private var sessionManager = ReadingSessionManager.shared
    @EnvironmentObject var appState: AppState

    @State private var selectedMode: NavigationMode = .surah
    @State private var showFavorites = false
    @State private var showBookmarks = false
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                // Creamy Papyrus Background
                CreamyPapyrusBackground()

                ScrollView {
                    VStack(spacing: 20) {
                    // Metrics Card with 3D shadow
                    QuranMetricsCard(
                        goalViewModel: goalViewModel,
                        sessionManager: sessionManager
                    )

                    // Continue/Start Reading Card with 3D shadow
                    QuranContinueReadingCard()

                    // Favorites & Bookmarks row
                    FavoritesBookmarksRow(
                        onFavoritesTapped: {
                            showFavorites = true
                        },
                        onBookmarksTapped: {
                            showBookmarks = true
                        }
                    )
                }
                .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(AppStrings.quran.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.Today.settingsIcon)
                    }
                }
            }
            .fullScreenCover(isPresented: $showFavorites) {
                FavoritesListView()
            }
            .fullScreenCover(isPresented: $showBookmarks) {
                BookmarksListView()
            }
        }
    }
}

#Preview {
    QuranMainView()
        .environmentObject(AppState())
}
