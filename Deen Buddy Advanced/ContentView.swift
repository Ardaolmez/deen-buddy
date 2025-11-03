//
//  ContentView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            TodayView()
                .tabItem {
                    Label(AppStrings.common.todayTab, systemImage: "calendar")
                }
                .tag(0)

            QuranView()
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
        .environmentObject(appState)
    }
}

#Preview {
    ContentView()
}
