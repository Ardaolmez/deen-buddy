//
//  DailyQuizCard.swift
//  Deen Buddy Advanced
//
//  Daily quiz card component
//

import SwiftUI

struct DailyQuizCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.Today.activityCardWhiteIcon)
                        .frame(width: 48, height: 48)

                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                // Title and time
                VStack(alignment: .leading, spacing: 4) {
                    Text(TodayStrings.dailyQuizLabel)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(0.5)

                    Text(TodayStrings.dailyQuizMinutes)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Start button
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                    Text(TodayStrings.dailyQuizStart)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColors.Today.activityCardWhiteIcon)
                .cornerRadius(12)
            }
            .padding(16)
            .frame(height: 80)
            .background(
                ZStack {
                    // Brand green gradient background
                    LinearGradient(
                        colors: [
                            AppColors.Today.brandGreen,
                            AppColors.Today.brandGreen.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Overlay gradient for depth
                    LinearGradient(
                        colors: [
                            AppColors.Today.gradientOverlayLight,
                            AppColors.Today.gradientOverlayMedium
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

#Preview {
    DailyQuizCard(onTap: {})
        .padding()
        .background(AppColors.Today.papyrusBackground)
}
