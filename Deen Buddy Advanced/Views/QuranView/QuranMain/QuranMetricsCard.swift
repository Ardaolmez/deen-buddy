//
//  QuranMetricsCard.swift
//  Deen Buddy Advanced
//
//  Metrics display card for Quran main page with 3D shadow styling
//

import SwiftUI

struct QuranMetricsCard: View {
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    @ObservedObject var sessionManager: ReadingSessionManager

    var body: some View {
        HStack(spacing: 12) {
            // Reading time
            metricItem(
                icon: "clock.fill",
                label: "Time",
                value: formatTime(sessionManager.elapsedSeconds),
                color: AppColors.Prayers.prayerGreen
            )

            Divider()
                .frame(height: 30)
                .background(Color(.systemGray4))

            // Daily goal progress (5 minutes)
            metricItem(
                icon: "target",
                label: "Goal",
                value: formatGoal(),
                color: AppColors.Prayers.prayerGreen
            )

            Divider()
                .frame(height: 30)
                .background(Color(.systemGray4))

            // Current streak
            metricItem(
                icon: "flame.fill",
                label: "Streak",
                value: "\(goalViewModel.readingGoal?.currentStreak ?? 0)",
                color: AppColors.Prayers.prayerGreen
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: 12)
    }

    // MARK: - Metric Item

    private func metricItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            // Value
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            // Label
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Time Formatter

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    // MARK: - Goal Formatter

    private func formatGoal() -> String {
        // Show live total minutes (same as what Today View uses)
        let liveMinutes = sessionManager.elapsedSeconds / 60
        return "\(liveMinutes)/5m"
    }
}

#Preview {
    QuranMetricsCard(
        goalViewModel: ReadingGoalViewModel.shared,
        sessionManager: ReadingSessionManager.shared
    )
    .padding()
    .background(Color(.systemBackground))
}
