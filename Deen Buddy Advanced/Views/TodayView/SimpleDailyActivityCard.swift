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

    private var iconName: String {
        switch activity.type {
        case .verse: return "book.fill"
        case .durood: return "hands.sparkles.fill"
        case .dua: return "heart.fill"
        }
    }

    private var backgroundImageName: String {
        switch activity.type {
        case .verse: return "tile.jpg"
        case .durood: return "Quba mosque painting.jpg"
        case .dua: return "tile.jpg"
        }
    }

    var body: some View {
        Button(action: {
            // If completed, allow users to view the detail again
            // If not completed, open detail view
            onShowDetail()
        }) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green.opacity(0.2) : Color.white.opacity(0.3))
                        .frame(width: 48, height: 48)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: iconName)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }

                // Title and time
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.type.displayName.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(0.5)

                    Text("\(activity.type.estimatedMinutes) MIN")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Read button or Done status
                if isCompleted {
                    Text("DONE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14))
                        Text("Read")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(12)
                }
            }
            .padding(16)
            .frame(height: 80)
            .background(
                ZStack {
                    // Background image
                    if let uiImage = UIImage(named: backgroundImageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 80)
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

                    // Overlay gradient
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

#Preview {
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
            onShowDetail: {}
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
            onShowDetail: {}
        )
    }
    .padding()
    .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
