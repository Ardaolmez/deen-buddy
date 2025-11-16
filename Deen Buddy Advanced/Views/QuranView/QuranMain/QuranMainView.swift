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

    var body: some View {
        NavigationView {
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
            .background(Color(.systemBackground).ignoresSafeArea())
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
