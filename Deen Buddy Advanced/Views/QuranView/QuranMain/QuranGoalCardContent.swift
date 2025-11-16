//
//  QuranGoalCardContent.swift
//  Deen Buddy Advanced
//
//  Content for Quran continue reading card with pencil icon
//

import SwiftUI

struct QuranGoalCardContent: View {
    @ObservedObject var viewModel: ReadingGoalViewModel
    @ObservedObject var sessionManager: ReadingSessionManager
    @Binding var showQuranReading: Bool
    @Binding var showListenTracking: Bool
    @Binding var showVerseNavigation: Bool

    private var isFirstTime: Bool {
        viewModel.getLastReadPosition() == nil
    }

    private var headerText: String {
        isFirstTime ? AppStrings.quran.startReading : AppStrings.quran.continueReading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Title + Goal metric
            HStack {
                Text(headerText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Today.quranGoalCardText)
                    .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
            }

            // Main content: Position + Pencil Icon + Progress Ring
            HStack(spacing: 12) {
                // Current position with pencil icon
                HStack(spacing: 8) {
                    if let positionInfo = viewModel.currentPositionInfo {
                        Text(positionInfo.displayText)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(AppColors.Today.quranGoalCardText)
                            .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.7), radius: 5, x: 0, y: 3)
                            .lineLimit(1)
                    }

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
                    showListenTracking = true
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
                        ZStack {
                            // Frosted glass blur
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thinMaterial)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.Today.buttonFrostedOverlay)
                        }
                    )
                }

                // Listen button - Navigate to Quran and play audio
                Button {
                    showQuranReading = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                            .font(.system(size: 14))
                        Text(AppStrings.today.listen)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.Today.quranGoalCardText.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            // Frosted glass blur
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.Today.buttonFrostedOverlay)
                        }
                    )
                }
                .disabled(true)
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
        let percentage = getProgressPercentage()
        let percentValue = Int(percentage * 100)
        return "\(percentValue)%"
    }
}
