//
//  StreakFeedbackOverlay.swift
//  Deen Buddy Advanced
//
//  Created by Claude on 2025-11-11.
//

import SwiftUI

struct StreakFeedbackOverlay: View {
    @Binding var isPresented: Bool
    let streakCount: Int
    let last7Days: [Bool]

    var body: some View {
        ZStack {
            // Dark background
            AppColors.Today.streakFeedbackBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Flame emoji
                Text("🔥")
                    .font(.system(size: 120))
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isPresented)

                // Streak count
                Text("\(streakCount)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(AppColors.Today.streakFeedbackCount)

                // Streak text
                Text(TodayStrings.streakDayLabel)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(AppColors.Today.streakFeedbackText)

                // Encouragement text
                Text(TodayStrings.streakEncouragement)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Today.streakFeedbackEncouragement)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 10)

                // Weekly calendar view
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        ForEach(TodayStrings.streakDayAbbreviations, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.Today.streakFeedbackDayText)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    HStack(spacing: 12) {
                        ForEach(Array(last7Days.enumerated()), id: \.offset) { index, isCompleted in
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? AppColors.Today.streakFeedbackCount : AppColors.Today.streakFeedbackDayInactive)
                                    .frame(width: 44, height: 44)

                                if isCompleted {
                                    Text("🔥")
                                        .font(.system(size: 20))
                                } else {
                                    Text("\(getDayNumber(for: index))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.Today.streakFeedbackDayNumber)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .background(AppColors.Today.streakFeedbackCalendarBg)
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer()

                // Done button
                Button(action: {
                    isPresented = false
                }) {
                    Text(TodayStrings.streakDoneButton)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.Today.streakFeedbackButtonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.Today.streakFeedbackButton)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    // Helper function to get day number for the week
    private func getDayNumber(for index: Int) -> Int {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the week (Sunday)
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!

        // Get the date for the specific index
        let targetDate = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
        let dayNumber = calendar.component(.day, from: targetDate)

        return dayNumber
    }
}

#Preview {
    StreakFeedbackOverlay(
        isPresented: .constant(true),
        streakCount: 2,
        last7Days: [false, true, true, false, false, false, false]
    )
}
