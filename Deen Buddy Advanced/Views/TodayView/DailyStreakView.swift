//
//  DailyStreakView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyStreakView: View {
    @Binding var streakDays: [Bool]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.Today.streakFlame)
                Text(AppStrings.common.dailyStreak)
                    .font(.system(size: 18, weight: .semibold))
            }

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(AppStrings.common.daysOfWeek[index])
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.Today.streakText)

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(streakDays[index] ? AppColors.Today.streakActive : AppColors.Today.streakInactive)
                                .frame(width: 40, height: 40)

                            if streakDays[index] {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppColors.Common.white)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(AppColors.Today.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DailyStreakView(
        streakDays: .constant([true, true, true, false, false, false, false])
    )
    .padding()
}
