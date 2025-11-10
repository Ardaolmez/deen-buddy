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

    // Random background image for this activity type
    private var backgroundImageName: String {
        switch currentActivity.type {
        case .verse:
            return BackgroundImageManager.shared.getRandomImage(for: .verse)
        case .durood:
            return BackgroundImageManager.shared.getRandomImage(for: .durood)
        case .dua:
            return BackgroundImageManager.shared.getRandomImage(for: .dua)
        }
    }

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
                    // Background - Beautiful Islamic artwork
                    ZStack {
                        // Base background color
                        AppColors.Today.cardBackground
                            .ignoresSafeArea()

                        // Random background image
                        if let image = UIImage(named: backgroundImageName) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                        } else {
                            // Fallback gradient background
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
                        }

                        // Dark overlay to make text more prominent
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()

                        // Additional gradient for depth
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
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
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)

                                // Progress fill
                                GeometryReader { progressGeometry in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: progressGeometry.size.width * CGFloat(currentProgress) / 100.0, height: 8)
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
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                        // Scrollable Content Area
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                // Reference at top
                                if let reference = currentActivity.reference {
                                    Text(reference)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(Color.orange)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)
                                }

                                // Arabic Text
                                Text(currentActivity.arabicText)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(12)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                                // Translation Label
                                Text("Translation")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.orange)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)

                                // English Translation
                                Text(currentActivity.translation)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white.opacity(0.95))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                                // Bottom padding for scroll
                                Spacer()
                                    .frame(height: 40)
                            }
                            .padding(.horizontal, 24)
                        }

                        // Action Buttons Section at the bottom
                        HStack(spacing: 12) {
                            // Share button
                            Button(action: {
                                // Share functionality
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
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
                                showChat = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 14))
                                    Text("Chat to learn more")
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
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
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
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
            .fullScreenCover(isPresented: $showChat) {
                ChatView(initialMessage: generateChatMessage())
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
