//
//  DailyActivityCard.swift
//  Deen Buddy Advanced
//
//  Expandable card for daily activities (Verse, Durood, Dua)
//

import SwiftUI

struct DailyActivityCard: View {
    let activity: DailyActivityContent
    let isCompleted: Bool
    let estimatedMinutes: Int
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? AppColors.Today.activityCardDone.opacity(0.1) : AppColors.Today.activityCardIconBackground)
                        .frame(width: 50, height: 50)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.Today.activityCardDone)
                    } else {
                        Image(systemName: activity.type.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.Today.activityCardIcon)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.type.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityCardTitle)

                    if isCompleted {
                        Text(AppStrings.today.activityDone)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.Today.activityCardDone)
                    } else {
                        Text(String(format: AppStrings.today.estimatedTime, estimatedMinutes))
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.Today.activityCardTime)
                    }
                }

                Spacer()

                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.Today.streakText)
            }
            .padding(16)
            .background(AppColors.Today.activityCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isCompleted ? AppColors.Today.activityCardDone.opacity(0.3) : AppColors.Today.activityCardBorder, lineWidth: 1.5)
            )
            .shadow(color: AppColors.Today.cardShadow.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 2)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyActivityCard(
            activity: DailyActivityContent(
                type: .verse,
                title: "Daily Verse",
                arabicText: "Test",
                translation: "Test translation",
                tags: []
            ),
            isCompleted: false,
            estimatedMinutes: 2,
            onTap: {}
        )

        DailyActivityCard(
            activity: DailyActivityContent(
                type: .durood,
                title: "Daily Durood",
                arabicText: "Test",
                translation: "Test translation",
                tags: []
            ),
            isCompleted: true,
            estimatedMinutes: 2,
            onTap: {}
        )
    }
    .padding()
}
