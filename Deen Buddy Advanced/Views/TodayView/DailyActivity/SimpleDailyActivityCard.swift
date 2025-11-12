//
//  SimpleDailyActivityCard.swift
//  Deen Buddy Advanced
//
//  Simple card for daily activities (Verse, Durood, Dua) with Read button
//

import SwiftUI

struct SimpleDailyActivityCard: View {
    let activity: DailyActivityContent
    let isCompleted: Bool
    let onMarkComplete: () -> Void
    let onShowDetail: () -> Void
    @Binding var isExpanded: Bool

    private var iconName: String {
        switch activity.type {
        case .verse: return "book.fill"
        case .durood: return "hands.sparkles.fill"
        case .dua: return "heart.fill"
        }
    }

    private var backgroundImageName: String {
        // Get random image for each activity type (stable per day)
        switch activity.type {
        case .verse:
            return BackgroundImageManager.shared.getRandomImage(for: .verse)
        case .durood:
            return BackgroundImageManager.shared.getRandomImage(for: .durood)
        case .dua:
            return BackgroundImageManager.shared.getRandomImage(for: .dua)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header (tappable area)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    // Icon - smaller
                    ZStack {
                        Circle()
                            .fill(isCompleted ? AppColors.Today.activityCardCompletionBg : AppColors.Today.activityCardWhiteIcon)
                            .frame(width: 40, height: 40)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.Today.activityCardCompletionIcon)
                        } else {
                            Image(systemName: iconName)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }

                    // Title and time - more compact
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.type.displayName.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(0.5)

                        Text("\(activity.type.estimatedMinutes) MIN")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    // Chevron icon - expandable indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppColors.Today.buttonWhiteOverlay)
                        .clipShape(Circle())
                }
                .padding(12)
                .frame(height: 64)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded content
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            ZStack {
                // Background image
                if let uiImage = UIImage(named: backgroundImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } else {
                    // Fallback gradient
                    LinearGradient(
                        colors: [
                            AppColors.Today.fallbackGradientPurpleStart,
                            AppColors.Today.fallbackGradientPurpleEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

                // Dynamic overlay based on expansion state
                backgroundOverlay
            }
            .allowsHitTesting(false)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Divider
            Rectangle()
                .fill(AppColors.Today.buttonWhiteOverlayLight)
                .frame(height: 1)
                .padding(.horizontal, 12)

            VStack(alignment: .center, spacing: 16) {
                // Translation preview
                Text(activity.translation)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            // Action buttons
            HStack(spacing: 6) {
                // Read button - Frosted glass with brand color
                Button(action: {
                    onShowDetail()
                }) {
                    HStack(spacing: 6) {
                        Text(TodayStrings.activityReadButton)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            // Frosted glass blur
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thinMaterial)

                            // Dark overlay for contrast
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.Today.buttonFrostedOverlay)
                        }
                    )
                }

                // Listen button (disabled) - Frosted glass
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Text(TodayStrings.activityListenButton)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            // Frosted glass blur
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)

                            // Dark overlay
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.Today.buttonFrostedOverlay)
                        }
                    )
                }
                .disabled(true)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Background Overlay

    private var backgroundOverlay: some View {
        ZStack {
            if isExpanded {
                // Lighter overlay for expanded state - better readability
                AppColors.Today.activityCardExpandedOverlay

                LinearGradient(
                    colors: [
                        AppColors.Today.activityCardExpandedGradientLight,
                        AppColors.Today.activityCardExpandedGradientDark
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                // Dark overlay for collapsed state - dramatic look
                AppColors.Today.activityCardCollapsedOverlay

                LinearGradient(
                    colors: [
                        AppColors.Today.activityCardCollapsedGradientLight,
                        AppColors.Today.activityCardCollapsedGradientDark
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var expanded1 = false
        @State private var expanded2 = false

        var body: some View {
            VStack(spacing: 16) {
                SimpleDailyActivityCard(
                    activity: DailyActivityContent(
                        type: .verse,
                        title: "Patience and Prayer",
                        arabicText: "Test",
                        translation: "Test translation",
                        tags: []
                    ),
                    isCompleted: false,
                    onMarkComplete: {},
                    onShowDetail: {},
                    isExpanded: $expanded1
                )

                SimpleDailyActivityCard(
                    activity: DailyActivityContent(
                        type: .durood,
                        title: "Durood Ibrahim",
                        arabicText: "Test",
                        translation: "Test translation",
                        tags: []
                    ),
                    isCompleted: true,
                    onMarkComplete: {},
                    onShowDetail: {},
                    isExpanded: $expanded2
                )
            }
            .padding()
            .background(AppColors.Today.papyrusBackground)
        }
    }

    return PreviewWrapper()
}
