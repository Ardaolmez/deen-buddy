//
//  SurahNavigationHelper.swift
//  Deen Buddy Advanced
//
//  Helper to navigate to specific verse from Surah/Juz selection
//

import SwiftUI

struct SurahNavigationHelper: View {
    let surahs: [Surah]
    let onNavigate: (Int, Int) -> Void
    @Binding var showPopup: Bool
    @State private var navigateToReading = false
    @State private var targetSurahId: Int?
    @State private var targetVerseId: Int?
    @ObservedObject private var goalViewModel = ReadingGoalViewModel.shared

    var body: some View {
        Color.clear
            .sheet(isPresented: $showPopup) {
                VerseNavigationPopup(
                    surahs: surahs,
                    onNavigate: { surahId, verseId in
                        targetSurahId = surahId
                        targetVerseId = verseId

                        // Update reading position
                        let absolutePosition = goalViewModel.getAbsolutePosition(surahId: surahId, verseId: verseId)
                        goalViewModel.updateCurrentPosition(to: absolutePosition)

                        // Open reading view
                        navigateToReading = true
                    }
                )
            }
            .fullScreenCover(isPresented: $navigateToReading) {
                VerseByVerseReadingView(
                    goalViewModel: goalViewModel,
                    isPresented: $navigateToReading
                )
            }
    }
}
