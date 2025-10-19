//
//  DailyReadingGoalCard.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyReadingGoalCard: View {
    @State private var progress: Double = 0.4 // 40% complete

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(AppColors.Today.readingGoalIcon)
                Text(AppStrings.today.dailyReadingGoal)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Today.readingGoalText)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.Today.readingGoalProgress))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text(String(format: AppStrings.today.pagesReadToday, 2, 5))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    // Continue reading action
                }) {
                    Text(AppStrings.today.continueReading)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.Today.readingGoalButton)
                }
            }
        }
        .padding()
        .background(AppColors.Today.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DailyReadingGoalCard()
}
