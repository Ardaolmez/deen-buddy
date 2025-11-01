//
//  GoalSelectionView.swift
//  Deen Buddy Advanced
//
//  Sheet view for selecting a new reading goal
//

import SwiftUI

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
