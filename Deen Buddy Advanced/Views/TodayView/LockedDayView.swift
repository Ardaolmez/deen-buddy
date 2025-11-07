//
//  LockedDayView.swift
//  Deen Buddy Advanced
//
//  Placeholder view for future/locked days
//

import SwiftUI

struct LockedDayView: View {
    let date: Date

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Calendar icon
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(Color(.systemGray4))

            VStack(spacing: 12) {
                Text("Not quite time yet.")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.Today.activityCardTitle)

                Text("Check back \(dateFormatter.string(from: date).lowercased()) for your Daily Plan session")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.Today.streakText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Text("Don't miss a day")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Today.activityCardTitle)
                .padding(.top, 20)

            Button(action: {
                // TODO: Implement reminder functionality
            }) {
                Text("Set a reminder")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Today.progressBarFill)
            }
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    LockedDayView(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
