//
//  DailyReadGoalCard.swift
//  Deen Buddy Advanced
//
//  Compact, expandable card for daily Quran reading goal
//

import SwiftUI

struct DailyReadGoalCard: View {
    var onGoalDetailRequested: (ReadingGoalViewModel) -> Void = { _ in }

    @ObservedObject private var viewModel = ReadingGoalViewModel.shared
    @ObservedObject private var sessionManager = ReadingSessionManager.shared
    @State private var showListenTracking: Bool = false
    @State private var showGoalSelection: Bool = false
    @State private var showQuranReading: Bool = false

    var body: some View {
        if viewModel.readingGoal == nil {
            // Show goal selection prompt
            GoalSelectionPrompt(showGoalSelection: $showGoalSelection)
                .sheet(isPresented: $showGoalSelection) {
                    GoalSelectionView(viewModel: viewModel)
                }
        } else {
            // Show active goal card
            goalCard
        }
    }

    // MARK: - Active Goal Card

    private var goalCard: some View {
        ZStack {
            // Main collapsed card - always visible
            GoalCardContent(
                viewModel: viewModel,
                sessionManager: sessionManager,
                showQuranReading: $showQuranReading,
                showListenTracking: $showListenTracking
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
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
    }
}

#Preview {
    GeometryReader { geometry in
        DailyReadGoalCard()
            .padding()
    }
}
