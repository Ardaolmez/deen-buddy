//
//  DailyActivityDetailView.swift
//  Deen Buddy Advanced
//
//  Full-screen modal displaying daily activity content
//

import SwiftUI

struct DailyActivityDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let activity: DailyActivityContent
    let isCompleted: Bool
    let onComplete: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                CreamyPapyrusBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with icon and estimated time
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.Today.activityCardIconBackground)
                                    .frame(width: 80, height: 80)

                                Image(systemName: activity.type.iconName)
                                    .font(.system(size: 36))
                                    .foregroundColor(AppColors.Today.activityCardIcon)
                            }

                            Text(activity.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.Today.activityCardTitle)
                                .multilineTextAlignment(.center)

                            if let reference = activity.reference {
                                Text(reference)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.Today.modalReferenceText)
                            }

                            // Estimated time badge
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                Text(String(format: AppStrings.today.estimatedTime, activity.type.estimatedMinutes))
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(AppColors.Today.activityCardTime)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.Today.activityCardIconBackground)
                            .cornerRadius(12)
                        }
                        .padding(.top, 20)

                        // Tags
                        if !activity.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(activity.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(AppColors.Today.modalTagText)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(AppColors.Today.modalTagBackground)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Arabic Text
                        VStack(alignment: .center, spacing: 16) {
                            Text(activity.arabicText)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(AppColors.Today.modalArabicText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.Today.activityCardBackground)
                                .cornerRadius(16)
                                .shadow(color: AppColors.Today.cardShadow, radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)

                        // Transliteration (if available)
                        if let transliteration = activity.transliteration {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Transliteration")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.Today.modalReferenceText)
                                    .textCase(.uppercase)

                                Text(transliteration)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(AppColors.Today.modalTranslationText)
                                    .italic()
                                    .lineSpacing(6)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(AppColors.Today.activityCardBackground)
                            .cornerRadius(16)
                            .shadow(color: AppColors.Today.cardShadow, radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }

                        // Translation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translation")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.Today.modalReferenceText)
                                .textCase(.uppercase)

                            Text(activity.translation)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(AppColors.Today.modalTranslationText)
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(AppColors.Today.activityCardBackground)
                        .cornerRadius(16)
                        .shadow(color: AppColors.Today.cardShadow, radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        // Complete button (only show if not completed)
                        if !isCompleted {
                            Button(action: {
                                onComplete()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text(AppStrings.today.markComplete)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppColors.Today.completeButton)
                                .foregroundColor(AppColors.Today.completeButtonText)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        } else {
                            // Completed badge
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text(AppStrings.today.activityDone)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.Today.activityCardDone.opacity(0.1))
                            .foregroundColor(AppColors.Today.activityCardDone)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.Today.activityCardDone, lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.Today.streakText)
                    }
                }
            }
        }
    }
}

#Preview {
    DailyActivityDetailView(
        activity: DailyActivityContent(
            type: .verse,
            title: "Patience and Prayer",
            arabicText: "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ",
            transliteration: "Wasta'eenoo bissabri wassalaah; wa innahaa lakabeeratun illaa 'alal khaashi'een",
            translation: "And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive to Allah.",
            reference: "Surah Al-Baqarah 2:45",
            tags: ["PATIENCE", "PRAYER", "HUMILITY"]
        ),
        isCompleted: false,
        onComplete: {}
    )
}
