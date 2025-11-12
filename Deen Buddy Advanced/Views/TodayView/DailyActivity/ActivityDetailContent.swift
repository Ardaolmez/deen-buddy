//
//  ActivityDetailContent.swift
//  Deen Buddy Advanced
//
//  Scrollable content component for daily activity detail view
//

import SwiftUI

struct ActivityDetailContent: View {
    let activity: DailyActivityContent
    let geometryWidth: CGFloat

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Reference at top
                if let reference = activity.reference {
                    Text(reference)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityDetailReference)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                        .padding(.top, 20)
                }

                // Arabic Text
                Text(activity.arabicText)
                    .font(.system(size: min(geometryWidth * 0.065, 26), weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(12)
                    .minimumScaleFactor(0.7)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                // Translation Label
                Text(TodayStrings.activityTranslationLabel)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.Today.activityDetailTranslationLabel)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                // English Translation
                Text(activity.translation)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .minimumScaleFactor(0.85)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                // Bottom padding for scroll
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: geometryWidth)
        }
    }
}
