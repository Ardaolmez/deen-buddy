//
//  TodayView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct TodayView: View {
    @State private var streakDays: [Bool] = [true, true, true, false, false, false, false]
    @State private var showQuiz = false
    @State private var showFeedback = false
    @State private var showGoalDetail = false
    @State private var goalDetailViewModel: ReadingGoalViewModel?
    @StateObject private var prayersVM = PrayersViewModel()
    @StateObject private var dailyProgressVM = DailyProgressViewModel()
    @State private var selectedActivity: DailyActivityContent?
    @State private var showActivityDetail = false
    @State private var showStreakFeedback = false
    @State private var streakCount = 0
    @State private var weeklyStreak: [Bool] = []

    var body: some View {
        NavigationView {
            ZStack {
                // Background (adapts to light/dark mode)
                CreamyPapyrusBackground()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            // Journey Header
//                            JourneyHeaderView(
//                                journeyTitle: dailyProgressVM.isSelectedDateToday() ? "Today's Journey" : "Journey",
//                                journeySubtitle: "Understanding Stress in Life",
//                                streakCount: dailyProgressVM.currentStreak,
//                                selectedDate: dailyProgressVM.selectedDate
//                            )

                            // Weekly Streak Section
                            WeeklyStreakView(
                                progress: dailyProgressVM.getProgressForSelectedDate(),
                                streakDays: dailyProgressVM.last7Days,
                                selectedDate: dailyProgressVM.selectedDate,
                                onDaySelected: { date in
                                    dailyProgressVM.selectedDate = date
                                }
                            )
                            .padding(.horizontal, 20)

                            // Content based on selected date
                            if dailyProgressVM.shouldLockSelectedDate() {
                                // Show locked view for future dates and past dates with no progress
                                LockedDayView(date: dailyProgressVM.selectedDate)
                                    .padding(.horizontal, 20)
                            } else {
                                // Daily Activity Cards - Show for today and past dates with progress
                                VStack(spacing: 16) {
                                    // Daily Verse
                                    if let verse = dailyProgressVM.dailyVerse {
                                        SimpleDailyActivityCard(
                                            activity: verse,
                                            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(.verse),
                                            onMarkComplete: {
                                                // Only allow marking complete if it's today
                                                if dailyProgressVM.isSelectedDateToday() {
                                                    dailyProgressVM.markActivityComplete(.verse)
                                                }
                                            },
                                            onShowDetail: {
                                                selectedActivity = verse
                                                showActivityDetail = true
                                            }
                                        )
                                    }

                                    // Daily Durood
                                    if let durood = dailyProgressVM.dailyDurood {
                                        SimpleDailyActivityCard(
                                            activity: durood,
                                            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(.durood),
                                            onMarkComplete: {
                                                // Only allow marking complete if it's today
                                                if dailyProgressVM.isSelectedDateToday() {
                                                    dailyProgressVM.markActivityComplete(.durood)
                                                }
                                            },
                                            onShowDetail: {
                                                selectedActivity = durood
                                                showActivityDetail = true
                                            }
                                        )
                                    }

                                    // Daily Dua
                                    if let dua = dailyProgressVM.dailyDua {
                                        SimpleDailyActivityCard(
                                            activity: dua,
                                            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(.dua),
                                            onMarkComplete: {
                                                // Only allow marking complete if it's today
                                                if dailyProgressVM.isSelectedDateToday() {
                                                    dailyProgressVM.markActivityComplete(.dua)
                                                }
                                            },
                                            onShowDetail: {
                                                selectedActivity = dua
                                                showActivityDetail = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Beautiful separator
                            DailyTasksSeparator()
                                .padding(.horizontal, 20)

                            // Word of Wisdom Card
                            WordOfWisdomCard()
                                .padding(.horizontal, 20)

                            // Daily Quiz Button - styled to match activity cards
                            Button(action: {
                                showQuiz = true
                            }) {
                                HStack(spacing: 12) {
                                    // Icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 48, height: 48)

                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }

                                    // Title and time
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("DAILY QUIZ")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .tracking(0.5)

                                        Text("5 MIN")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                    }

                                    Spacer()

                                    // Start button
                                    HStack(spacing: 6) {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 14))
                                        Text("Start")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(12)
                                }
                                .padding(16)
                                .frame(height: 80)
                                .background(
                                    ZStack {
                                        // Brand green gradient background
                                        LinearGradient(
                                            colors: [
                                                AppColors.Today.brandGreen,
                                                AppColors.Today.brandGreen.opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )

                                        // Overlay gradient for depth
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0.3)
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
                            .padding(.horizontal, 20)

                            // Daily Reading Goal
                            DailyReadGoalCard { viewModel in
                                goalDetailViewModel = viewModel
                                showGoalDetail = true
                            }
                            .padding(.horizontal, 20)

                            // Chat Box
                            ChatBoxView()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .id("chatBox")
                        }
                        .padding(.top, 16)
                    }
                    .onAppear {
                        // Set up the streak completion callback
                        dailyProgressVM.onDailyStreakCompleted = { streak, last7Days in
                            streakCount = streak
                            weeklyStreak = last7Days
                            showStreakFeedback = true
                        }

                        // Scroll to bottom with a slight delay to ensure layout is complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("chatBox", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle(AppStrings.today.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PrayerTimeCompact(nextPrayer: prayersVM.nextPrayer)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFeedback = true
                    }) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(AppColors.Today.settingsIcon)
                    }
                }
            }
            .fullScreenCover(isPresented: $showQuiz) {
                QuizView()
            }
            .fullScreenCover(isPresented: $showGoalDetail) {
                if let viewModel = goalDetailViewModel {
                    GoalDetailOverlay(
                        viewModel: viewModel,
                        isPresented: $showGoalDetail
                    )
                } else {
                    EmptyView()
                }
            }
            .onChange(of: showGoalDetail) { isPresented in
                if !isPresented {
                    goalDetailViewModel = nil
                }
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackPopupView()
            }
            .fullScreenCover(isPresented: $showActivityDetail) {
                if let activity = selectedActivity {
                    DailyActivityDetailView(
                        activity: activity,
                        isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(activity.type),
                        onComplete: {
                            dailyProgressVM.markActivityComplete(activity.type)
                        },
                        allActivities: getAllActivities(),
                        dailyProgress: dailyProgressVM.getProgressForSelectedDate(),
                        checkIsCompleted: { type in
                            dailyProgressVM.isActivityCompletedForSelectedDate(type)
                        },
                        markComplete: { type in
                            dailyProgressVM.markActivityComplete(type)
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showStreakFeedback) {
                StreakFeedbackOverlay(
                    isPresented: $showStreakFeedback,
                    streakCount: streakCount,
                    last7Days: weeklyStreak
                )
            }
        }
    }

    // MARK: - Helper Functions

    private func getAllActivities() -> [DailyActivityContent] {
        var activities: [DailyActivityContent] = []
        if let verse = dailyProgressVM.dailyVerse {
            activities.append(verse)
        }
        if let durood = dailyProgressVM.dailyDurood {
            activities.append(durood)
        }
        if let dua = dailyProgressVM.dailyDua {
            activities.append(dua)
        }
        return activities
    }
}

#Preview {
    TodayView()
}
