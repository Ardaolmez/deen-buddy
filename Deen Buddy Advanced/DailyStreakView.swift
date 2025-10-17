//
//  DailyStreakView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyStreakView: View {
    @Binding var streakDays: [Bool]
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.Today.streakFlame)
                Text("Daily Streak")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(daysOfWeek[index])
                            .font(.caption)
                            .foregroundColor(AppColors.Today.streakText)

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(streakDays[index] ? AppColors.Today.streakActive : AppColors.Today.streakInactive)
                                .frame(width: 40, height: 40)

                            if streakDays[index] {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppColors.Common.white)
                                    .font(.system(size: 20))
                            }
                        }
                    }
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
    DailyStreakView(streakDays: .constant([true, true, true, false, false, false, false]))
}
