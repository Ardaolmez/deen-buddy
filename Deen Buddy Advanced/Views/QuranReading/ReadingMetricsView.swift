//
//  ReadingMetricsView.swift
//  Deen Buddy Advanced
//
//  Enhanced reading metrics UI with real-time feedback and progress visualization
//

import SwiftUI

struct ReadingMetricsView: View {
    @ObservedObject var sessionManager: ReadingSessionManager
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    @ObservedObject var screenManager = ScreenDimensionManager.shared
    
    @State private var showDetailedMetrics: Bool = false
    @State private var animateMetrics: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimal header with timer and goal
            minimalHeader
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(AppColors.Reading.pageCenter)

            // Thin progress line
            progressIndicatorLine
        }
    }
    
    // MARK: - Minimal Header

    private var minimalHeader: some View {
        HStack(spacing: 12) {
            // Session timer - smaller
            Text(sessionManager.formattedTime)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.Reading.headerTimer)

            Spacer()

            // Daily goal progress - compact
            if let goal = goalViewModel.readingGoal {
                Text(getDailyProgressText(for: goal))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(getDailyProgressColor(for: goal))
            }
        }
    }
    

    



    
    // MARK: - Progress Indicator Line
    
    private var progressIndicatorLine: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background line
                Rectangle()
                    .fill(AppColors.Reading.progressRingBackground)
                    .frame(height: 3)
                
                // Progress line
                Rectangle()
                    .fill(AppColors.Reading.progressFill)
                    .frame(width: geometry.size.width * sessionManager.progressPercentage, height: 3)
                    .animation(.easeInOut(duration: 0.5), value: sessionManager.progressPercentage)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Helper Methods

    private func getDailyProgressText(for goal: ReadingGoal) -> String {
        if goal.goalType.isTimeBased {
            // For time-based goals (5 minutes daily)
            let remainingMinutes = max(0, goal.goalType.minutesPerDay - goal.todayActivity.totalMinutes)
            return remainingMinutes == 0 ? "Daily Goal Reached!" : "\(remainingMinutes)m left"
        } else {
            // For verse-based goals
            let remainingVerses = max(0, goal.goalType.versesPerDay - goal.todayActivity.totalVerses)
            return remainingVerses == 0 ? "Daily Goal Reached!" : "\(remainingVerses)v left"
        }
    }

    private func getDailyProgressColor(for goal: ReadingGoal) -> Color {
        let dailyProgress: Double

        if goal.goalType.isTimeBased {
            dailyProgress = Double(goal.todayActivity.totalMinutes) / Double(max(goal.goalType.minutesPerDay, 1))
        } else {
            dailyProgress = Double(goal.todayActivity.totalVerses) / Double(max(goal.goalType.versesPerDay, 1))
        }

        return dailyProgress >= 1.0 ? AppColors.Reading.progressRingGoal : AppColors.Reading.darkBackgroundMid
    }

}

// MARK: - Preview

#Preview {
    ReadingMetricsView(
        sessionManager: ReadingSessionManager(),
        goalViewModel: ReadingGoalViewModel()
    )
    .background(AppColors.Reading.background)
}
