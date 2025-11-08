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
    let allActivities: [DailyActivityContent]
    let dailyProgress: Int
    let checkIsCompleted: (DailyActivityType) -> Bool

    @State private var currentActivity: DailyActivityContent
    @State private var currentIsCompleted: Bool
    @State private var currentProgress: Int

    init(activity: DailyActivityContent,
         isCompleted: Bool,
         onComplete: @escaping () -> Void,
         allActivities: [DailyActivityContent] = [],
         dailyProgress: Int = 0,
         checkIsCompleted: @escaping (DailyActivityType) -> Bool = { _ in false }) {
        self.activity = activity
        self.isCompleted = isCompleted
        self.onComplete = onComplete
        self.allActivities = allActivities
        self.dailyProgress = dailyProgress
        self.checkIsCompleted = checkIsCompleted
        self._currentActivity = State(initialValue: activity)
        self._currentIsCompleted = State(initialValue: isCompleted)
        self._currentProgress = State(initialValue: dailyProgress)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background - Scenic gradient to simulate nature image
                ZStack {
                    // Base gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.45, blue: 0.5),
                            Color(red: 0.3, green: 0.4, blue: 0.45),
                            Color(red: 0.2, green: 0.3, blue: 0.35)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    // Overlay for depth
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    // Progress Section at the top - Fixed
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Progress today")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(currentProgress)%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.yellow)
                        }

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)

                                // Progress fill
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(currentProgress) / 100.0, height: 8)
                                    .animation(.easeInOut, value: currentProgress)
                            }
                        }
                        .frame(height: 8)

                        // Activity type badge
                        HStack(spacing: 8) {
                            Image(systemName: currentActivity.type.iconName)
                                .font(.system(size: 16))
                            Text(currentActivity.type.displayName.uppercased())
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1)
                            Text("• \(currentActivity.type.estimatedMinutes) MIN")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    // Scrollable Content Area
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Reference at top
                            if let reference = currentActivity.reference {
                                Text(reference)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.orange)
                                    .padding(.top, 20)
                            }

                            // Arabic Text
                            Text(currentActivity.arabicText)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(12)
                                .padding(.horizontal, 30)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .fixedSize(horizontal: false, vertical: true)

                            // Translation Label
                            Text("Translation")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color.orange)
                                .padding(.top, 8)

                            // English Translation
                            Text(currentActivity.translation)
                                .font(.system(size: 19, weight: .regular))
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 30)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .fixedSize(horizontal: false, vertical: true)

                            // Bottom padding for scroll
                            Spacer()
                                .frame(height: 40)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Action Buttons Section at the bottom
                    HStack(spacing: 12) {
                        // Share button
                        Button(action: {
                            // Share functionality
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.2))
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                        }

                        // Chat to learn more button
                        Button(action: {
                            // Chat functionality
                        }) {
                            HStack(spacing: 8) {
                                Text("Chat to learn more")
                                    .font(.system(size: 16, weight: .medium))
                                Image(systemName: "message.fill")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                        }

                        // Next button
                        if !currentIsCompleted {
                            Button(action: {
                                handleComplete()
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 64, height: 64)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    Text("Today's Journey")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Helper Functions

    private func handleComplete() {
        // Mark current activity as complete
        onComplete()
        currentIsCompleted = true

        // Update progress
        updateProgress()

        // Find next uncompleted activity
        if let nextActivity = findNextActivity() {
            // Delay to show completion before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentActivity = nextActivity
                    currentIsCompleted = checkIsCompleted(nextActivity.type)
                }
            }
        } else {
            // All activities completed, dismiss the view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func updateProgress() {
        let total = allActivities.count
        guard total > 0 else { return }

        let completed = allActivities.filter { checkIsCompleted($0.type) }.count
        let newProgress = Int((Double(completed) / Double(total)) * 100)

        withAnimation(.easeInOut(duration: 0.5)) {
            currentProgress = newProgress
        }
    }

    private func findNextActivity() -> DailyActivityContent? {
        guard !allActivities.isEmpty else { return nil }

        // Find current activity index
        guard let currentIndex = allActivities.firstIndex(where: { $0.type == currentActivity.type }) else {
            return nil
        }

        // Look for next activity in the list that is not completed
        for index in (currentIndex + 1)..<allActivities.count {
            let activity = allActivities[index]
            if !checkIsCompleted(activity.type) {
                return activity
            }
        }

        return nil
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
