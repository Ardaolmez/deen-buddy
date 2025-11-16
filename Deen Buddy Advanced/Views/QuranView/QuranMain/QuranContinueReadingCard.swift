//
//  QuranContinueReadingCard.swift
//  Deen Buddy Advanced
//
//  Enhanced reading card for Quran main page with 3D shadow effect
//

import SwiftUI

struct QuranContinueReadingCard: View {
    @ObservedObject private var viewModel = ReadingGoalViewModel.shared
    @ObservedObject private var sessionManager = ReadingSessionManager.shared
    @State private var showListenTracking: Bool = false
    @State private var showQuranReading: Bool = false
    @State private var showVerseNavigation: Bool = false
    @State private var showGoalSelection: Bool = false
    @State private var pendingNavigation: (surahId: Int, verseId: Int)? = nil

    var body: some View {
        if viewModel.readingGoal == nil {
            // Show goal selection prompt
            GoalSelectionPrompt(showGoalSelection: $showGoalSelection)
                .sheet(isPresented: $showGoalSelection) {
                    GoalSelectionView(viewModel: viewModel)
                }
        } else {
            // Show active goal card with enhanced 3D shadow
            goalCard
        }
    }

    // MARK: - Active Goal Card

    private var goalCard: some View {
        VStack(spacing: 12) {
            // Main card
            ZStack {
                // Main card content
                QuranGoalCardContent(
                    viewModel: viewModel,
                    sessionManager: sessionManager,
                    showQuranReading: $showQuranReading,
                    showListenTracking: $showListenTracking,
                    showVerseNavigation: $showVerseNavigation
                )
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(GoalCardBackground(imageOpacity: 0.8, imageBlur: 1.1, gradientOpacity: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.Today.buttonWhiteOverlayLight,  // Bright at top
                                    Color.clear   // Fade to transparent
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                // Enhanced 3D multi-layer shadow
           //     .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
             //   .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
              //  .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            // Verse selection button under the card with green-toned 3D shadows
            Button(action: {
                showVerseNavigation = true
            }) {
                Text(AppStrings.reading.selectVerse)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.Today.brandGreen)
                    .cornerRadius(12)
                    // Green-toned shadows matching the button color
                    .shadow(color: AppColors.Today.brandGreen.opacity(0.15), radius: 4, x: 0, y: 2)
                    .shadow(color: AppColors.Today.brandGreen.opacity(0.25), radius: 12, x: 0, y: 6)
                    .shadow(color: AppColors.Today.brandGreen.opacity(0.2), radius: 24, x: 0, y: 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .fullScreenCover(isPresented: $showListenTracking) {
            VerseByVerseReadingView(
                goalViewModel: viewModel,
                isPresented: $showListenTracking
            )
        }
        .fullScreenCover(isPresented: $showQuranReading) {
            QuranReadingView(
                goalViewModel: viewModel,
                isPresented: $showQuranReading
            )
        }
        .sheet(isPresented: $showVerseNavigation) {
            VerseNavigationPopup(
                surahs: viewModel.getSurahs(),
                onNavigate: { surahId, verseId in
                    // Store the navigation target instead of opening immediately
                    pendingNavigation = (surahId, verseId)
                }
            )
        }
        .onChange(of: showVerseNavigation) { isShowing in
            // When sheet is dismissed and we have a pending navigation, execute it
            if !isShowing, let target = pendingNavigation {
                // Small delay to ensure smooth transition after sheet dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    navigateToVerse(surahId: target.surahId, verseId: target.verseId)
                    pendingNavigation = nil
                }
            }
        }
    }

    // MARK: - Navigation

    private func navigateToVerse(surahId: Int, verseId: Int) {
        // Calculate absolute position
        let absolutePosition = viewModel.getAbsolutePosition(surahId: surahId, verseId: verseId)

        // Update goal position
        viewModel.updateCurrentPosition(to: absolutePosition)

        // Open reading view
        showListenTracking = true
    }
}

#Preview {
    QuranContinueReadingCard()
        .padding()
        .background(Color(.systemBackground))
}
