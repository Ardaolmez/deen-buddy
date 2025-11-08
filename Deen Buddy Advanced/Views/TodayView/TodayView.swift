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
                            if dailyProgressVM.isSelectedDateFuture() {
                                // Show locked view for future dates
                                LockedDayView(date: dailyProgressVM.selectedDate)
                                    .padding(.horizontal, 20)
                            } else {
                                // Daily Activity Cards
                                VStack(spacing: 16) {
                                    // Daily Verse
                                    if let verse = dailyProgressVM.dailyVerse {
                                        SimpleDailyActivityCard(
                                            activity: verse,
                                            isCompleted: dailyProgressVM.isActivityCompletedForSelectedDate(.verse),
                                            onMarkComplete: {
                                                dailyProgressVM.markActivityComplete(.verse)
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
                                                dailyProgressVM.markActivityComplete(.durood)
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
                                                dailyProgressVM.markActivityComplete(.dua)
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

                            // Daily Quran Verse (Keep original if needed)
                            DailyVerseCard()
                                .padding(.horizontal, 20)

                            // Daily Quiz Button
                            Button(action: {
                                showQuiz = true
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text(AppStrings.today.dailyQuiz)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppColors.Today.dailyQuizButton)
                                .foregroundColor(AppColors.Today.dailyQuizText)
                                .cornerRadius(16)
                            }
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
                        }
                    )
                }
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
