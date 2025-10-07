//
//  ContentView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            QuranView()
                .tabItem {
                    Label("Quran", systemImage: "book.closed")
                }
                .tag(1)

            PrayersView()
                .tabItem {
                    Label("Prayers", systemImage: "moon.stars")
                }
                .tag(2)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
