//
//  JourneyHeaderView.swift
//  Deen Buddy Advanced
//
//  Journey header with title, subtitle, and streak info
//

import SwiftUI

struct JourneyHeaderView: View {
    let journeyTitle: String
    let journeySubtitle: String
    let streakCount: Int
    let selectedDate: Date

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        HStack(alignment: .top) {
            // User Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [Color(red: 0.8, green: 0.7, blue: 0.3), Color(red: 0.9, green: 0.8, blue: 0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 56, height: 56)
                .overlay(
                    Text("M")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(isToday ? "Today's Journey" : "\(dateFormatter.string(from: selectedDate))'s Journey")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.Today.activityCardTitle)

                // Subtitle
                Text(journeySubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Today.streakText)
            }

            Spacer()

            // Streak and Calendar icons
            HStack(spacing: 12) {
                // Streak indicator
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.Today.streakFlame)
                    Text("\(streakCount)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityCardTitle)
                }

                Divider()
                    .frame(height: 20)

                // Calendar icon
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.Today.activityCardTitle)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

#Preview {
    JourneyHeaderView(
        journeyTitle: "Today's Journey",
        journeySubtitle: "Understanding Stress in Life",
        streakCount: 1,
        selectedDate: Date()
    )
}
