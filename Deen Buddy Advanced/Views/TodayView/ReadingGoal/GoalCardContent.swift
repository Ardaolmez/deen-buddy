//
//  GoalCardContent.swift
//  Deen Buddy Advanced
//
//  Main collapsed content for active reading goal card
//

import SwiftUI

struct GoalCardContent: View {
    @ObservedObject var viewModel: ReadingGoalViewModel
    @ObservedObject var sessionManager: ReadingSessionManager
    @Binding var showQuranReading: Bool
    @Binding var showListenTracking: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Title + Goal metric
            HStack {
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Today.quranGoalCardText)
                    .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
                Text(viewModel.goalMetricText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Today.quranGoalCardText)
                    .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
            }

            // Main content: Position + Progress Ring
            HStack(spacing: 12) {
                // Current position - takes most space
                if let positionInfo = viewModel.currentPositionInfo {
                    Text(positionInfo.displayText)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(AppColors.Today.quranGoalCardText)
                        .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.7), radius: 5, x: 0, y: 3)
                        .lineLimit(1)
                }

                Spacer()

                // Small progress ring on the right
                SmallProgressRing(
                    progress: getProgressPercentage(),
                    text: getProgressText()
                )
                .frame(width: 44, height: 44)
            }

            Spacer()

            // Read / Listen Buttons
            HStack(spacing: 10) {
                // Read button - Filled with brand color
                Button {
                    showQuranReading = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14))
                        Text(AppStrings.today.read)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.Today.quranGoalCardText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        AppColors.Today.quranGoalBrandColor,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }

                // Listen button - Filled with brand color
                Button {
                    showListenTracking = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                            .font(.system(size: 14))
                        Text(AppStrings.today.listen)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.Today.quranGoalCardText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        AppColors.Today.quranGoalBrandColor,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
        }
    }

    // MARK: - Progress Helpers

    private func getProgressPercentage() -> Double {
        guard let goal = viewModel.readingGoal else { return 0.0 }

        if goal.goalType.isTimeBased {
            let totalMinutes = sessionManager.elapsedSeconds / 60
            let percentage = Double(totalMinutes) / Double(goal.goalType.minutesPerDay)
            return min(percentage, 1.0)
        } else {
            let percentage = Double(goal.todayActivity.totalVerses) / Double(goal.goalType.versesPerDay)
            return min(percentage, 1.0)
        }
    }

    private func getProgressText() -> String {
        guard let goal = viewModel.readingGoal else { return "0" }

        if goal.goalType.isTimeBased {
            let totalMinutes = sessionManager.elapsedSeconds / 60
            return "\(totalMinutes)/\(goal.goalType.minutesPerDay)"
        } else {
            return "\(goal.todayActivity.totalVerses)/\(goal.goalType.versesPerDay)"
        }
    }
}
