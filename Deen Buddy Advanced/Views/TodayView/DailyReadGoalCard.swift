//
//  DailyReadGoalCard.swift
//  Deen Buddy Advanced
//
//  Compact, expandable card for daily Quran reading goal
//

import SwiftUI

struct DailyReadGoalCard: View {
    @StateObject private var viewModel = ReadingGoalViewModel()
    @ObservedObject private var sessionManager = ReadingSessionManager.shared
    @State private var isExpanded: Bool = false
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
            .background(GoalCardBackground(imageOpacity: 0.8, imageBlur: 1.1, gradientOpacity: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.Today.quranGoalBrandColor.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.04), radius: 2, x: 0, y: 1)
            .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: AppColors.Today.quranGoalBrandColor.opacity(0.05), radius: 16, x: 0, y: 8)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $showListenTracking) {
            VerseByVerseReadingView(
                goalViewModel: viewModel,
                isPresented: $showListenTracking
            )
        }
        .fullScreenCover(isPresented: $isExpanded) {
            GoalDetailOverlay(
                viewModel: viewModel,
                isPresented: $isExpanded
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
