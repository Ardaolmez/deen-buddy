//
//  ReadingHeaderView.swift
//  Deen Buddy Advanced
//
//  Header view for Quran reading session with timer and progress
//

import SwiftUI

struct ReadingHeaderView: View {
    @ObservedObject var sessionManager: ReadingSessionManager
    let currentSurahName: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with timer, goal, position
            HStack(spacing: 16) {
                // Close button
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.Reading.closeButton)
                }

                Spacer()

                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.Reading.headerTimer)

                    Text(sessionManager.formattedTime)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppColors.Reading.headerTimer)
                }

                Text("|")
                    .foregroundColor(AppColors.Reading.headerGoal.opacity(0.5))

                // Goal
                Text(AppStrings.reading.goal)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Reading.headerGoal)

                Text("|")
                    .foregroundColor(AppColors.Reading.headerPosition.opacity(0.5))

                // Current Surah
                Text(currentSurahName)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(AppColors.Reading.headerPosition)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppColors.Reading.headerBackground)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(AppColors.Reading.progressBackground)
                        .frame(height: 4)

                    // Progress fill
                    Rectangle()
                        .fill(AppColors.Reading.progressFill)
                        .frame(width: geometry.size.width * sessionManager.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    ReadingHeaderPreviewWrapper()
}

struct ReadingHeaderPreviewWrapper: View {
    @State private var isPresented = true
    @StateObject private var sessionManager = ReadingSessionManager()

    var body: some View {
        ReadingHeaderView(
            sessionManager: sessionManager,
            currentSurahName: "Al-Baqarah",
            isPresented: $isPresented
        )
        .onAppear {
            sessionManager.startSession()
        }
    }
}
