//
//  ContentView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @ObservedObject private var appLanguageManager = AppLanguageManager.shared
    @State private var showLaunchScreen = true

    var body: some View {
        ZStack {
            // Main TabView
            TabView(selection: $appState.selectedTab) {
                TodayView()
                    .tabItem {
                        Label(AppStrings.common.todayTab, systemImage: "calendar")
                    }
                    .tag(0)

                QuranMainView()
                    .tabItem {
                        Label(AppStrings.common.quranTab, systemImage: "book.closed")
                    }
                    .tag(1)

                PrayersView()
                    .tabItem {
                        Label(AppStrings.common.prayersTab, systemImage: "moon.stars")
                    }
                    .tag(2)

                ExploreView()
                    .tabItem {
                        Label(AppStrings.common.exploreTab, systemImage: "safari")
                    }
                    .tag(3)
            }
            .id(appLanguageManager.currentLanguage)
            .environmentObject(appState)

            // Launch Screen Overlay
            if showLaunchScreen {
                QuoteLaunchView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunchScreen = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
