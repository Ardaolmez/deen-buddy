//
//  ActivityDetailActionBar.swift
//  Deen Buddy Advanced
//
//  Action bar component for daily activity detail view
//

import SwiftUI

struct ActivityDetailActionBar: View {
    let onShare: () -> Void
    let onChat: () -> Void
    let onNext: () -> Void
    let safeAreaBottom: CGFloat
    var isLastActivity: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Share button
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.Today.activityDetailShareBg)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    )
            }

            // Chat to learn more button
            Button(action: onChat) {
                HStack(spacing: 6) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 14))
                    Text(TodayStrings.activityChatToLearnMore)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.Today.activityDetailChatBg)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                )
            }

            // Next/Done button - shows checkmark on last activity
            Button(action: onNext) {
                Image(systemName: isLastActivity ? "checkmark" : "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.Today.activityDetailNextButtonText)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.Today.activityDetailNextButton)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, max(safeAreaBottom, 16))
    }
}
