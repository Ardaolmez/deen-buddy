//
//  DailyReadGoalCard.swift
//  Deen Buddy Advanced
//
//  Compact, expandable card for daily Quran reading goal
//

import SwiftUI

struct DailyReadGoalCard: View {
    @StateObject private var viewModel = ReadingGoalViewModel()
    @State private var isExpanded: Bool = false
    @State private var showReadTracking: Bool = false
    @State private var showListenTracking: Bool = false
    @State private var showGoalSelection: Bool = false

    var body: some View {
        if viewModel.readingGoal == nil {
            // Show goal selection prompt
            goalSelectionPrompt
        } else {
            // Show active goal card
            goalCard
        }
    }

    // MARK: - Goal Selection Prompt

    private var goalSelectionPrompt: some View {
        Button {
            showGoalSelection = true
        } label: {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(AppColors.Today.quranGoalButtonRead)
                Text(AppStrings.today.dailyQuranGoal)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Today.quranGoalTitle)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.Today.quranGoalButtonRead)
            }
            .padding()
            .background(AppColors.Today.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
        }
        .sheet(isPresented: $showGoalSelection) {
            GoalSelectionView(viewModel: viewModel)
        }
    }

    // MARK: - Active Goal Card

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapsed View
            collapsedContent

            // Expanded View
            if isExpanded {
                Divider()
                    .padding(.vertical, 12)
                expandedContent
            }
        }
        .padding()
        .background(AppColors.Today.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
        .sheet(isPresented: $showReadTracking) {
            ReadingGoalTrackingView(viewModel: viewModel, mode: .reading)
        }
        .sheet(isPresented: $showListenTracking) {
            ReadingGoalTrackingView(viewModel: viewModel, mode: .listening)
        }
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + Goal Metric
            HStack {
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.headline)
                    .foregroundColor(AppColors.Today.quranGoalTitle)
                Spacer()
                Text(viewModel.goalMetricText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Today.quranGoalMetric)
            }

            // Current Position (Surah:Verse)
            if let positionInfo = viewModel.currentPositionInfo {
                Text(positionInfo.displayText)
                    .font(.system(.title2, design: .serif).weight(.semibold))
                    .foregroundColor(AppColors.Today.quranGoalSurah)
            }

            // Status + Remaining
            HStack(spacing: 4) {
                Text(viewModel.statusText)
                    .font(.subheadline)
                    .foregroundColor(viewModel.statusColor)

                Text("•")
                    .foregroundColor(AppColors.Today.quranGoalRemaining)

                Text(viewModel.remainingText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Today.quranGoalRemaining)
            }

            // Read / Listen Buttons
            HStack(spacing: 12) {
                Button {
                    showReadTracking = true
                } label: {
                    HStack {
                        Image(systemName: "book.fill")
                        Text(AppStrings.today.read)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.Today.quranGoalButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.Today.quranGoalButtonRead)
                    .cornerRadius(10)
                }

                Button {
                    // Listening feature coming soon
                    // showListenTracking = true
                } label: {
                    HStack {
                        Image(systemName: "headphones")
                        Text(AppStrings.today.listen)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.Today.quranGoalButtonText.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.Today.quranGoalButtonListen.opacity(0.3))
                    .cornerRadius(10)
                }
                .disabled(true)
            }

            // Expand hint
            HStack {
                Spacer()
                Text(isExpanded ? AppStrings.today.tapToCollapse : AppStrings.today.tapForDetails)
                    .font(.caption)
                    .foregroundColor(AppColors.Today.quranGoalExpandHint)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(AppColors.Today.quranGoalExpandHint)
                Spacer()
            }
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
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
                        value: "Verse \(goal.expectedVersePosition)"
                    )

                    detailRow(
                        label: AppStrings.today.actual,
                        value: "Verse \(positionInfo.absoluteVersePosition)"
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
    }

    // MARK: - Helper Views

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

// MARK: - Goal Selection View

struct GoalSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ReadingGoalViewModel
    @State private var selectedGoalType: ReadingGoalType?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach([
                        ReadingGoalType.completion1Week,
                        ReadingGoalType.completion2Weeks,
                        ReadingGoalType.completion1Month,
                        ReadingGoalType.completion3Months
                    ], id: \.self) { goalType in
                        goalTypeRow(goalType)
                    }
                } header: {
                    Text(AppStrings.today.completionGoals)
                }

                Section {
                    goalTypeRow(.microLearning5Minutes)
                } header: {
                    Text(AppStrings.today.microLearningGoals)
                }
            }
            .navigationTitle(AppStrings.today.selectYourGoal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.today.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.today.startGoal) {
                        if let selected = selectedGoalType {
                            viewModel.createGoal(type: selected)
                            dismiss()
                        }
                    }
                    .disabled(selectedGoalType == nil)
                }
            }
        }
    }

    private func goalTypeRow(_ goalType: ReadingGoalType) -> some View {
        Button {
            selectedGoalType = goalType
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goalType.displayName)
                        .font(.body)
                        .foregroundColor(AppColors.Common.primary)

                    if goalType.isTimeBased {
                        Text("\(goalType.minutesPerDay) \(AppStrings.today.minutes)")
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    } else {
                        Text("\(goalType.versesPerDay) \(AppStrings.today.verses)")
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }

                Spacer()

                if selectedGoalType == goalType {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.Today.quranGoalButtonRead)
                }
            }
        }
    }
}

#Preview {
    DailyReadGoalCard()
        .padding()
}
