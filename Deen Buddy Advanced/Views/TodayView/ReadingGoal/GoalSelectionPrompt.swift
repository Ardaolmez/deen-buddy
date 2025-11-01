//
//  GoalSelectionPrompt.swift
//  Deen Buddy Advanced
//
//  Prompt card shown when no reading goal is set
//

import SwiftUI

struct GoalSelectionPrompt: View {
    @Binding var showGoalSelection: Bool

    var body: some View {
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
                GoalCardBackground(imageOpacity: 1.0, imageBlur: 1.1, gradientOpacity: 0.7)
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
    }
}
