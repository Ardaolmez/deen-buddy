//
//  ActivityDetailProgressHeader.swift
//  Deen Buddy Advanced
//
//  Progress header component for daily activity detail view
//

import SwiftUI

struct ActivityDetailProgressHeader: View {
    let activity: DailyActivityContent
    let progress: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(TodayStrings.activityProgressToday)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(progress)%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.Today.activityDetailProgressPercent)
            }

            // Progress bar
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.Today.buttonWhiteOverlayLight)
                    .frame(height: 8)

                // Progress fill
                GeometryReader { progressGeometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.Today.activityDetailProgressGradientStart,
                                    AppColors.Today.activityDetailProgressGradientEnd
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: progressGeometry.size.width * CGFloat(progress) / 100.0, height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)

            // Activity type badge
            HStack(spacing: 8) {
                Image(systemName: activity.type.iconName)
                    .font(.system(size: 16))
                Text(activity.type.displayName.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1)
                Text("• " + String(format: AppStrings.today.estimatedTime, activity.type.estimatedMinutes))
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}
