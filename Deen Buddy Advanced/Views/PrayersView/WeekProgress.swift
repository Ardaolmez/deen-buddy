// Views/PrayersView/WeekProgress.swift
import SwiftUI

struct WeekProgress: View {
    let weekStatus: [Bool]

    private let weekdays = AppStrings.common.daysOfWeek
    private var completedDays: Int { weekStatus.filter { $0 }.count }
    private var streakText: String { completedDays == 7 ? AppStrings.prayers.perfect : "\(completedDays)/7" }

    var body: some View {
        VStack(spacing: MinimalDesign.mediumSpacing) {
            // Enhanced progress visualization
            HStack(spacing: MinimalDesign.smallSpacing) {
                ForEach(0..<7, id: \.self) { index in
                    let isCompleted = index < weekStatus.count && weekStatus[index]
                    let isToday = index == Calendar.current.component(.weekday, from: Date()) - 2

                    VStack(spacing: MinimalDesign.smallSpacing) {
                        // Weekday label
                        Text(weekdays[index])
                            .font(.system(.caption2, weight: .medium))
                            .foregroundStyle(isToday ? AppColors.Common.primary : AppColors.Common.secondary)

                        // Progress indicator
                        ZStack {
                            Circle()
                                .fill(isCompleted ? AppColors.Prayers.prayerGreen : AppColors.Prayers.subtleGray)
                                .frame(width: MinimalDesign.smallIcon, height: MinimalDesign.smallIcon)
                                .shadow(color: isCompleted ? AppColors.Prayers.greenShadow : .clear, radius: 2)

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(AppColors.Common.white)
                            }

                            // Today indicator
                            if isToday {
                                Circle()
                                    .stroke(AppColors.Prayers.prayerBlue, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColors.Prayers.subtleGray)
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(AppColors.Prayers.prayerGreen)
                        .frame(width: geometry.size.width * (Double(completedDays) / 7.0), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.5), value: completedDays)
                }
            }
            .frame(height: 4)
        }
    }
}
