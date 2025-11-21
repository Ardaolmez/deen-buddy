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
    let markComplete: (DailyActivityType) -> Void  // New: callback to mark any activity complete

    @State private var currentActivity: DailyActivityContent
    @State private var currentIsCompleted: Bool
    @State private var currentProgress: Int
    @State private var showChat = false

    init(activity: DailyActivityContent,
         isCompleted: Bool,
         onComplete: @escaping () -> Void,
         allActivities: [DailyActivityContent] = [],
         dailyProgress: Int = 0,
         checkIsCompleted: @escaping (DailyActivityType) -> Bool = { _ in false },
         markComplete: @escaping (DailyActivityType) -> Void = { _ in }) {
        self.activity = activity
        self.isCompleted = isCompleted
        self.onComplete = onComplete
        self.allActivities = allActivities
        self.dailyProgress = dailyProgress
        self.checkIsCompleted = checkIsCompleted
        self.markComplete = markComplete
        self._currentActivity = State(initialValue: activity)
        self._currentIsCompleted = State(initialValue: isCompleted)
        self._currentProgress = State(initialValue: dailyProgress)
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    ActivityDetailBackground(activityType: currentActivity.type)

                    VStack(spacing: 0) {
                        // Progress Section at the top - Fixed
                        ActivityDetailProgressHeader(
                            activity: currentActivity,
                            progress: currentProgress
                        )

                        // Scrollable Content Area
                        ActivityDetailContent(
                            activity: currentActivity,
                            geometryWidth: geometry.size.width
                        )

                        // Action Buttons Section at the bottom
                        ActivityDetailActionBar(
                            onShare: {
                                // Share functionality
                            },
                            onChat: {
                                showChat = true
                            },
                            onNext: {
                                navigateToNext()
                            },
                            safeAreaBottom: geometry.safeAreaInsets.bottom
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
               
                ToolbarItem(placement: .principal) {
                    Text(TodayStrings.activityTodaysJourney)
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
            .fullScreenCover(isPresented: $showChat) {
                ChatView(initialMessage: generateChatMessage())
            }
            .onAppear {
                // Auto-mark as complete when view opens
                markAsComplete()
            }
        }
    }

    // MARK: - Helper Functions

    private func generateChatMessage() -> String {
        let activityName = currentActivity.type.displayName
        let reference = currentActivity.reference ?? ""
        let translation = currentActivity.translation

        // Create a contextual message based on activity type
        var message = "I would like to learn more about this \(activityName)"

        if !reference.isEmpty {
            message += " (\(reference))"
        }

        message += ".\n\n"
        message += "The translation is: \"\(translation)\"\n\n"
        message += "Please tell me about:\n"
        message += "• Its significance and context\n"
        message += "• The meaning and benefits\n"
        message += "• When and how to use it\n"
        message += "• Any related teachings or lessons"

        return message
    }

    private func markAsComplete() {
        // Mark the current activity as complete
        if !currentIsCompleted {
            markComplete(currentActivity.type)
            currentIsCompleted = true
            updateProgress()
        }
    }

    private func navigateToNext() {
        guard !allActivities.isEmpty else { return }

        // Find current activity index
        guard let currentIndex = allActivities.firstIndex(where: { $0.type == currentActivity.type }) else {
            return
        }

        // Get next index (cycle back to 0 if at the end)
        let nextIndex = (currentIndex + 1) % allActivities.count
        let nextActivity = allActivities[nextIndex]

        withAnimation(.easeInOut(duration: 0.3)) {
            currentActivity = nextActivity
            currentIsCompleted = checkIsCompleted(nextActivity.type)
            // Mark new activity as complete when we navigate to it
            markAsComplete()
        }
    }

    private func handleComplete() {
        // Mark the CURRENT activity as complete (not the original one)
        markComplete(currentActivity.type)
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
