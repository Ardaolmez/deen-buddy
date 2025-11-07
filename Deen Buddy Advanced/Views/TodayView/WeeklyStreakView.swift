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
        VStack(spacing: 16) {
            // Days of week
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(AppStrings.common.daysOfWeek[index])
                        .font(.system(size: 13, weight: .medium))
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
                                    isSelected ? AppColors.Today.streakFlame :
                                    hasProgress ? AppColors.Today.streakFlame.opacity(0.6) :
                                    isPast && !hasProgress ? Color(.systemGray2) :  // Darker border for past incomplete
                                    Color(.systemGray4),
                                    lineWidth: isSelected ? 3 : 2
                                )
                                .background(
                                    Circle()
                                        .fill(
                                            isSelected && hasProgress ? AppColors.Today.streakFlame.opacity(0.15) :
                                            isSelected ? Color(.systemGray5) :
                                            hasProgress ? AppColors.Today.streakFlame.opacity(0.1) :
                                            isPast && !hasProgress ? Color(.systemGray4) :  // Darker background for past incomplete
                                            Color(.systemGray6)
                                        )
                                )
                                .frame(width: 44, height: 44)

                            if hasProgress {
                                // Show flame for completed days
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppColors.Today.streakFlame)
                                    .font(.system(size: 20))
                            } else if isPast && !hasProgress {
                                // Show lock icon for past incomplete days (not clickable)
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(.systemGray))
                                    .font(.system(size: 14))
                            } else if isFuture {
                                // Show day number for future days (clickable to show "not quite time yet")
                                let dayNumber = getDayNumber(for: index)
                                if dayNumber > 0 {
                                    Text("\(dayNumber)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(.systemGray2))
                                }
                            } else {
                                // Today or other edge cases
                                let dayNumber = getDayNumber(for: index)
                                if dayNumber > 0 {
                                    Text("\(dayNumber)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(.systemGray2))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(isClickable ? 1.0 : 0.7)  // Slightly more visible for locked days
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isClickable)
                }
            }

            // Progress section
            VStack(spacing: 12) {
                HStack {
                    Text(progressText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityCardTitle)

                    Spacer()

                    Text("\(progress)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(progress == 100 ? AppColors.Today.activityCardDone : AppColors.Today.progressBarFill)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.95, green: 0.93, blue: 0.88))
                            .frame(height: 8)

                        if progress > 0 {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.7, blue: 0.3), Color(red: 1.0, green: 0.5, blue: 0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress) / 100.0, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
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

        // Past days are only clickable if they have progress
        return hasProgress
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
