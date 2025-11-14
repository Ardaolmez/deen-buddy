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
            VStack(spacing: 12) {
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
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.Today.wisdomQuoteText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(10)
                        .minimumScaleFactor(0.7)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .padding(.top, 5)
                        .padding(.horizontal, 24)

                    // Author - Quote Attribution Style
                    if let author = activity.reference {
                        Text("\(author)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppColors.Today.wisdomAuthorText)
                            .multilineTextAlignment(.leading)
                            .italic()
                            .padding(.top, 8)
                            .padding(.horizontal, 24)
                    }

                    // Explanation Label
                    Text("Explanation")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.Today.activityDetailTranslationLabel)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)

                    // Explanation - EMPHASIZED (MOST IMPORTANT)
                    Text(activity.translation)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(9)
                        .minimumScaleFactor(0.85)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 24)
                } else {
                    // Verse/Durood/Dua: Show Arabic Text
                    if let arabicText = activity.arabicText {
                        Text(arabicText)
                            .font(.system(size: min(geometryWidth * 0.06, 24), weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(12)
                            .minimumScaleFactor(0.7)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 24)
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
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .minimumScaleFactor(0.85)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 24)
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
