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
                            .fill(isCompleted ? Color.green.opacity(0.2) : Color.white.opacity(0.3))
                            .frame(width: 40, height: 40)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
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
                        .background(Color.white.opacity(0.2))
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
                            Color(red: 0.4, green: 0.3, blue: 0.6),
                            Color(red: 0.3, green: 0.2, blue: 0.5)
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
                .fill(Color.white.opacity(0.3))
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
                        Text("Read")
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
                                .fill(Color.black.opacity(0.1))
                        }
                    )
                }

                // Listen button (disabled) - Frosted glass
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Text("Listen")
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
                                .fill(Color.black.opacity(0.1))
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
                Color.black.opacity(0.5)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                // Dark overlay for collapsed state - dramatic look
                Color.black.opacity(0.5)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.4)
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
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        }
    }

    return PreviewWrapper()
}
