//
//  GoalDetailOverlay.swift
//  Deen Buddy Advanced
//
//  Full-screen overlay showing detailed goal statistics
//

import SwiftUI

struct GoalDetailOverlay: View {
    @ObservedObject var viewModel: ReadingGoalViewModel
    @Binding var isPresented: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9

    var body: some View {
        ZStack {
            // Semi-transparent background
            AppColors.Today.quranGoalOverlayBackground.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    dismissWithAnimation()
                }

            // Content card
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(AppStrings.today.dailyQuranGoal)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.Today.quranGoalTitle)

                    Spacer()

                    Button(action: {
                        dismissWithAnimation()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.Common.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding()
                .background(AppColors.Today.cardBackground.opacity(0.95))

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Today's Progress
                        sectionHeader(AppStrings.today.todaysProgress)

                        if let goal = viewModel.readingGoal {
                            detailRow(
                                label: AppStrings.today.goal,
                                value: goal.goalType.isTimeBased ?
                                    "\(goal.goalType.minutesPerDay) \(AppStrings.today.minutes)" :
                                    "\(goal.goalType.versesPerDay) \(AppStrings.today.verses)"
                            )

                            detailRow(
                                label: AppStrings.today.completed,
                                value: goal.goalType.isTimeBased ?
                                    "\(goal.todayActivity.totalMinutes) \(AppStrings.today.minutes)" :
                                    "\(goal.todayActivity.totalVerses) \(AppStrings.today.verses)"
                            )

                            detailRow(
                                label: AppStrings.today.remaining,
                                value: goal.goalType.isTimeBased ?
                                    "\(goal.todayRemainingMinutes) \(AppStrings.today.minutes)" :
                                    "\(goal.todayRemainingVerses) \(AppStrings.today.verses)"
                            )

                            Divider()
                                .padding(.vertical, 4)

                            // Timeline
                            sectionHeader(AppStrings.today.timeline)

                            if let positionInfo = viewModel.currentPositionInfo {
                                detailRow(
                                    label: AppStrings.today.expected,
                                    value: "\(AppStrings.today.versePrefix)\(goal.expectedVersePosition)"
                                )

                                detailRow(
                                    label: AppStrings.today.actual,
                                    value: "\(AppStrings.today.versePrefix)\(positionInfo.absoluteVersePosition)"
                                )

                                detailRow(
                                    label: AppStrings.today.status,
                                    value: viewModel.statusText
                                )
                            }

                            Divider()
                                .padding(.vertical, 4)

                            // Streak
                            sectionHeader(AppStrings.today.streak)

                            detailRow(
                                label: AppStrings.today.current,
                                value: "\(goal.currentStreak) \(goal.currentStreak == 1 ? AppStrings.today.day : AppStrings.today.days)"
                            )

                            detailRow(
                                label: AppStrings.today.best,
                                value: "\(goal.bestStreak) \(goal.bestStreak == 1 ? AppStrings.today.day : AppStrings.today.days)"
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(AppColors.Today.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: AppColors.Today.quranGoalCardShadow.opacity(0.2), radius: 20, x: 0, y: 10)
            .frame(maxWidth: min(UIScreen.main.bounds.width * 0.9, 500))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                opacity = 1
                scale = 1
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            opacity = 0
            scale = 0.9
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(AppColors.Today.quranGoalSectionHeader)
            .textCase(.uppercase)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(AppColors.Today.quranGoalDetailText)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(AppColors.Today.quranGoalDetailText)
        }
    }
}
