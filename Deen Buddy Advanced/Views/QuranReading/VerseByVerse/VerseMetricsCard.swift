//
//  VerseMetricsCard.swift
//  Deen Buddy Advanced
//
//  Fancy metrics display card for verse-by-verse reading
//

import SwiftUI

struct VerseMetricsCard: View {
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    @ObservedObject var sessionManager: ReadingSessionManager

    var body: some View {
        HStack(spacing: 12) {
            // Reading time
            metricItem(
                icon: "clock.fill",
                label: QuranStrings.metricTime,
                value: formatTime(sessionManager.elapsedSeconds),
                color: AppColors.VerseByVerse.accentGreen
            )

            Divider()
                .frame(height: 30)
                .background(AppColors.VerseByVerse.metricsDivider)

            // Daily goal progress (5 minutes)
            metricItem(
                icon: "target",
                label: QuranStrings.metricGoal,
                value: formatGoal(),
                color: AppColors.VerseByVerse.progressGoal
            )

            Divider()
                .frame(height: 30)
                .background(AppColors.VerseByVerse.metricsDivider)

            // Current streak
            metricItem(
                icon: "flame.fill",
                label: QuranStrings.metricStreak,
                value: "\(goalViewModel.readingGoal?.currentStreak ?? 0)",
                color: AppColors.VerseByVerse.progressStreak
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.VerseByVerse.accentGreen.opacity(0.3), lineWidth: 1.5)
        )
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
                .foregroundColor(AppColors.VerseByVerse.textPrimary)

            // Label
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.VerseByVerse.metricsLabel)
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

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.VerseByVerse.backgroundGradient
            .ignoresSafeArea()

        VerseMetricsCard(
            goalViewModel: ReadingGoalViewModel.shared,
            sessionManager: ReadingSessionManager.shared
        )
        .padding()
    }
}
