//
//  DailyProgressStreakView.swift
//  Deen Buddy Advanced
//
//  Enhanced daily streak view with progress tracking
//

import SwiftUI

struct DailyProgressStreakView: View {
    let currentStreak: Int
    let progress: Int
    let streakDays: [Bool]

    var body: some View {
        VStack(spacing: 16) {
            // Header with streak count and progress
            HStack {
                // Streak indicator
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.Today.streakFlame)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppStrings.today.dailyStreakTitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Today.progressText)
                        Text("\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppColors.Today.streakText)
                    }
                }

                Spacer()

                // Progress indicator
                HStack(spacing: 8) {
                    Text(AppStrings.today.progressToday)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Today.progressText)

                    Text("\(progress)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(progress == 100 ? AppColors.Today.activityCardDone : AppColors.Today.progressBarFill)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Today.progressBarBackground)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Today.progressBarFill)
                        .frame(width: geometry.size.width * CGFloat(progress) / 100.0, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)

            // Weekly streak visualization
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
                                    .font(.system(size: 16))
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
    DailyProgressStreakView(
        currentStreak: 5,
        progress: 66,
        streakDays: [true, true, true, true, true, false, false]
    )
    .padding()
}
