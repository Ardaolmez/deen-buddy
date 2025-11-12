//
//  ExpandableDailyActivityCard.swift
//  Deen Buddy Advanced
//
//  Expandable card with background image for daily activities
//

import SwiftUI

struct ExpandableDailyActivityCard: View {
    let activity: DailyActivityContent
    let isCompleted: Bool
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onMarkComplete: () -> Void

    @State private var showDetail = false

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
            // Compact header - always visible
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.25))
                        .frame(width: 40, height: 40)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: iconName)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }

                // Title and time
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.type.displayName.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(0.5)

                    if !isExpanded {
                        Text("\(activity.type.estimatedMinutes) MIN")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                // Status or expand indicator
                if isCompleted {
                    Text("DONE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(12)
                } else {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    onToggleExpand()
                }
            }

            // Expanded content
            if isExpanded {
                VStack(spacing: 16) {
                    // Title
                    Text(activity.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            // TODO: Implement listen functionality
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "headphones")
                                    .font(.system(size: 16))
                                Text("Listen")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(12)
                        }
                        .allowsHitTesting(true)

                        Button(action: {
                            showDetail = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 16))
                                Text("Read")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(12)
                        }
                        .allowsHitTesting(true)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
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
                        .frame(height: isExpanded ? 200 : 72)
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

                // Dark overlay to make text more prominent
                Color.black.opacity(0.5)

                // Additional gradient for depth
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .frame(height: isExpanded ? 200 : 72)
        .cornerRadius(20)
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .sheet(isPresented: $showDetail) {
            DailyActivityDetailView(
                activity: activity,
                isCompleted: isCompleted,
                onComplete: onMarkComplete
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ExpandableDailyActivityCard(
            activity: DailyActivityContent(
                type: .verse,
                title: "Patience and Prayer",
                arabicText: "Test",
                translation: "Test translation",
                tags: []
            ),
            isCompleted: false,
            isExpanded: true,
            onToggleExpand: {},
            onMarkComplete: {}
        )

        ExpandableDailyActivityCard(
            activity: DailyActivityContent(
                type: .durood,
                title: "Durood Ibrahim",
                arabicText: "Test",
                translation: "Test translation",
                tags: []
            ),
            isCompleted: false,
            isExpanded: false,
            onToggleExpand: {},
            onMarkComplete: {}
        )
    }
    .padding()
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
