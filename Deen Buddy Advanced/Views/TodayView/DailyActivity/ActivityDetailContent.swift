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
                // Reference at top (for verse/durood/dua)
                if activity.type != .wisdom, let reference = activity.reference {
                    Text(reference)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityDetailReference)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                        .padding(.top, 20)
                }

                // Main Content - Different for wisdom vs others
                if activity.type == .wisdom {
                    // Wisdom: Show quote - less prominent
                    Text("\"\(activity.title)\"")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .minimumScaleFactor(0.7)
                        .italic()
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .padding(.top, 20)
                        .padding(.horizontal, 16)

                    // Author - PROMINENT ORANGE
                    if let author = activity.reference {
                        Text("- \(author)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.Today.wisdomAuthorText)
                            .multilineTextAlignment(.center)
                           // .padding(.top, 12)
                    }

                    // Explanation Label
                    Text("EXPLANATION")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityDetailTranslationLabel)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)

                    // Explanation - EMPHASIZED (MOST IMPORTANT)
                    Text(activity.translation)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(9)
                        .minimumScaleFactor(0.85)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 20)
                } else {
                    // Verse/Durood/Dua: Show Arabic Text
                    if let arabicText = activity.arabicText {
                        Text(arabicText)
                            .font(.system(size: min(geometryWidth * 0.06, 24), weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(12)
                            .minimumScaleFactor(0.7)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }

                    // Translation Label
                    Text(TodayStrings.activityTranslationLabel)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityDetailTranslationLabel)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    // English Translation - EMPHASIZED
                    Text(activity.translation)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .minimumScaleFactor(0.85)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 8)
                }

                // Bottom padding for scroll
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: geometryWidth)
        }
    }
}
