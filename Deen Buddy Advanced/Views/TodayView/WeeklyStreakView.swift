//
//  WeeklyStreakView.swift
//  Deen Buddy Advanced
//
//  Clean weekly streak visualization matching reference design
//

import SwiftUI

struct WeeklyStreakView: View {
    let progress: Int
    let streakDays: [Bool]
    let selectedDate: Date
    let onDaySelected: (Date) -> Void

    private var progressText: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Progress today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "Progress for \(formatter.string(from: selectedDate))"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Days of week
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(AppStrings.common.daysOfWeek[index])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.Today.streakText)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day circles with flames - clickable
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    let dayDate = getDate(for: index)
                    let isSelected = Calendar.current.isDate(dayDate, inSameDayAs: selectedDate)
                    let isClickable = isDayClickable(dayDate, hasProgress: streakDays[index])
                    let isFuture = dayDate > Date()
                    let isPast = dayDate < Date() && !Calendar.current.isDateInToday(dayDate)
                    let hasProgress = streakDays[index]

                    Button(action: {
                        if isClickable {
                            onDaySelected(dayDate)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .strokeBorder(
                                    isSelected ? AppColors.Today.brandGreen :
                                    hasProgress ? AppColors.Today.brandGreen.opacity(0.6) :
                                    isPast && !hasProgress ? Color(.systemGray3) :
                                    Color(.systemGray4),
                                    lineWidth: isSelected ? 2.5 : 1.5
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected && hasProgress ? AppColors.Today.brandGreen.opacity(0.15) :
                                            isSelected ? Color(.systemGray5) :
                                            hasProgress ? AppColors.Today.brandGreen.opacity(0.1) :
                                            isPast && !hasProgress ? Color(.systemGray5) :
                                            Color(.systemGray6)
                                        )
                                )
                                .frame(width: 38, height: 38)

                            if hasProgress {
                                // Show flame for completed days
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppColors.Today.brandGreen)
                                    .font(.system(size: 18))
                            } else {
                                // Show day number for all non-completed days
                                let dayNumber = getDayNumber(for: index)
                                if dayNumber > 0 {
                                    Text("\(dayNumber)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(isSelected ? Color(.systemGray) : Color(.systemGray2))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isClickable)
                }
            }

            // Progress section
            VStack(spacing: 8) {
                HStack {
                    Text(progressText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityCardTitle)

                    Spacer()

                    Text("\(progress)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.Today.brandGreen)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.95, green: 0.93, blue: 0.88))
                            .frame(height: 6)

                        if progress > 0 {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppColors.Today.brandGreen.opacity(0.5),
                                            AppColors.Today.brandGreen
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress) / 100.0, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 12)
    }

    private func getDayNumber(for index: Int) -> Int {
        let dayDate = getDate(for: index)
        return Calendar.current.component(.day, from: dayDate)
    }

    private func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())
        let daysBackToSunday = todayWeekday - 1

        guard let sunday = calendar.date(byAdding: .day, value: -daysBackToSunday, to: Date()) else {
            return Date()
        }

        guard let dayDate = calendar.date(byAdding: .day, value: index, to: sunday) else {
            return Date()
        }

        return dayDate
    }

    private func isDayClickable(_ date: Date, hasProgress: Bool) -> Bool {
        let today = Date()
        let calendar = Calendar.current

        // Future days are clickable (to show locked screen)
        if date > today {
            return true
        }

        // Today is always clickable
        if calendar.isDateInToday(date) {
            return true
        }

        // All past days are clickable - allow viewing history
        return true
    }
}

#Preview {
    WeeklyStreakView(
        progress: 100,
        streakDays: [true, true, true, false, true, false, false],
        selectedDate: Date(),
        onDaySelected: { _ in }
    )
    .padding()
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
