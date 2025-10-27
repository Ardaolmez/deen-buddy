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
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.Today.quranGoalButtonRead)
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.Today.quranGoalTitle)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.Today.quranGoalButtonRead)
            }
            .padding(20)
            
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
        ZStack {
            // Main collapsed card - always visible
            VStack(alignment: .leading, spacing: 0) {
                collapsedContent
            }
            .padding(20)
            
            .frame(maxWidth: .infinity)
            .background(AppColors.Today.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
        }
        .sheet(isPresented: $showReadTracking) {
            ReadingGoalTrackingView(viewModel: viewModel, mode: .reading)
        }
        .sheet(isPresented: $showListenTracking) {
            ReadingGoalTrackingView(viewModel: viewModel, mode: .listening)
        }
        .fullScreenCover(isPresented: $isExpanded) {
            GoalDetailOverlay(
                viewModel: viewModel,
                isPresented: $isExpanded
                
            )
        }
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title + Goal Metric
            HStack {
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.Today.quranGoalTitle)
                Spacer()
                Text(viewModel.goalMetricText)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.Today.quranGoalMetric)
            }

            // Current Position (Surah:Verse)
            if let positionInfo = viewModel.currentPositionInfo {
                Text(positionInfo.displayText)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(AppColors.Today.quranGoalSurah)
                    .lineLimit(1)
            }

            // Status + Remaining
            HStack(spacing: 4) {
                Text(viewModel.statusText)
                    .font(.system(size: 13))
                    .foregroundColor(viewModel.statusColor)

                Text("•")
                    .foregroundColor(AppColors.Today.quranGoalRemaining)

                Text(viewModel.remainingText)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.Today.quranGoalRemaining)
            }

            Spacer()

            // Read / Listen Buttons
            HStack(spacing: 10) {
                Button {
                    showReadTracking = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14))
                        Text(AppStrings.today.read)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.Today.quranGoalButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppColors.Today.quranGoalButtonRead)
                    .cornerRadius(8)
                }

                Button {
                    // Listening feature coming soon
                    // showListenTracking = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                            .font(.system(size: 14))
                        Text(AppStrings.today.listen)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.Today.quranGoalButtonText.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppColors.Today.quranGoalButtonListen.opacity(0.3))
                    .cornerRadius(8)
                }
                .disabled(true)
            }
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

// MARK: - Goal Detail Overlay

struct GoalDetailOverlay: View {
    @ObservedObject var viewModel: ReadingGoalViewModel
    @Binding var isPresented: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
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
                    .padding()
                }
            }
            .background(AppColors.Today.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
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

#Preview {
    GeometryReader { geometry in
        DailyReadGoalCard()
            .padding()
    }
}
