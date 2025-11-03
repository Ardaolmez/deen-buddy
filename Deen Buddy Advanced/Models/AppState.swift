//
//  AppState.swift
//  Deen Buddy Advanced
//
//  App-wide state management for navigation and shared state
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var navigateToQuranWithAudio: Bool = false
    @Published var targetSurahID: Int? = nil
    @Published var targetVerseIndex: Int = 0

    func navigateToQuranAndPlay(surahID: Int, verseIndex: Int = 0) {
        targetSurahID = surahID
        targetVerseIndex = verseIndex
        selectedTab = 1  // Quran tab
        navigateToQuranWithAudio = true
    }

    func resetNavigationFlag() {
        navigateToQuranWithAudio = false
    }
}
