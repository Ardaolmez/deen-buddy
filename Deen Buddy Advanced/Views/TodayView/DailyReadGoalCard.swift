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
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 3)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
            }
            .padding(20)

            .background(
                ZStack {
                    // Base background color
                    AppColors.Today.cardBackground

                    // Mosque painting background
                    if let image = UIImage(named: "Quba mosque painting.jpg") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(1)
                    }

                    // Subtle gradient overlay for text readability
                    LinearGradient(
                        colors: [
                            AppColors.Today.cardBackground.opacity(0.7),
                            AppColors.Today.cardBackground.opacity(0.5),
                            AppColors.Today.cardBackground.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.Today.quranGoalBrandColor.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: AppColors.Today.quranGoalBrandColor.opacity(0.05), radius: 16, x: 0, y: 8)
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
            .background(
                ZStack {
                    // Base background color
                    AppColors.Today.cardBackground

                    // Mosque painting background
                    if let image = UIImage(named: "Quba mosque painting.jpg") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.8)
                            .blur(radius: 1.1)
                    }

                    // Subtle gradient overlay for text readability
                    LinearGradient(
                        colors: [
                            AppColors.Today.cardBackground.opacity(0.1),
                            AppColors.Today.cardBackground.opacity(0.1),
                            AppColors.Today.cardBackground.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.Today.quranGoalBrandColor.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: AppColors.Today.quranGoalBrandColor.opacity(0.05), radius: 16, x: 0, y: 8)
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

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Title + Goal metric
            HStack {
                Text(AppStrings.today.dailyQuranGoal)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                Text(viewModel.goalMetricText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
            }

            // Main content: Position + Progress Ring
            HStack(spacing: 12) {
                // Current position - takes most space
                if let positionInfo = viewModel.currentPositionInfo {
                    Text(positionInfo.displayText)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 3)
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        AppColors.Today.quranGoalBrandColor,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }

                // Listen button - Filled with purple
                Button {
                    showListenTracking = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                            .font(.system(size: 14))
                        Text(AppStrings.today.listen)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
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
