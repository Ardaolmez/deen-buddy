//
//  TodayView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct TodayView: View {
    @State private var showQuiz = false
    @State private var showFeedback = false
    @State private var showGoalDetail = false
    @State private var goalDetailViewModel: ReadingGoalViewModel?
    @StateObject private var prayersVM = PrayersViewModel()
    @StateObject private var dailyProgressVM = DailyProgressViewModel()
    @StateObject private var quizVM = QuizViewModel()
    @State private var selectedActivity: DailyActivityContent?
    @State private var showActivityDetail = false
    @State private var showStreakFeedback = false
    @State private var streakCount = 0
    @State private var weeklyStreak: [Bool] = []
    @State private var expandedActivity: DailyActivityType? = .verse  // First card expanded by default

    // Quiz card state
    @State private var selectedQuestionIndex: Int? = nil
    @State private var showQuizView = false
    @State private var showQuizResults = false

    // Navigation title state for scroll-based updates
    @State private var currentNavigationTitle = TodayStrings.navigationTitle

    var body: some View {
        NavigationView {
            ZStack {
                // Background (adapts to light/dark mode)
                CreamyPapyrusBackground()

                VStack(spacing: 0) {
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
                                DailyActivitiesSection(
                                    dailyProgressVM: dailyProgressVM,
                                    onActivitySelected: { activity in
                                        selectedActivity = activity
                                        showActivityDetail = true
                                    },
                                    expandedActivity: $expandedActivity
                                )
                            }

                            // Beautiful separator
                            DailyTasksSeparator()
                                .padding(.horizontal, 20)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(
                                                key: ViewOffsetKey.self,
                                                value: geometry.frame(in: .named("scroll")).minY
                                            )
                                    }
                                )
                                .onPreferenceChange(ViewOffsetKey.self) { offset in
                                    // Update title when separator crosses threshold
                                    if offset < 200 {
                                        currentNavigationTitle = TodayStrings.selfLearningTitle
                                    } else {
                                        currentNavigationTitle = TodayStrings.navigationTitle
                                    }
                                }

                            // Word of Wisdom Card
//                            WordOfWisdomCard()
  //                              .padding(.horizontal, 20)

                            // Daily Quiz Card (new non-linear design)
                            DailyQuizCardNew(
                                quizViewModel: quizVM,
                                selectedQuestionIndex: $selectedQuestionIndex,
                                showQuizView: $showQuizView,
                                showQuizResults: $showQuizResults
                            )
                            .padding(.horizontal, 20)

                            // Daily Reading Goal
                            DailyReadGoalCard { viewModel in
                                goalDetailViewModel = viewModel
                                showGoalDetail = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100) // Add bottom padding for sticky chat
                            }
                            .padding(.top, 16)
                        }
                        .coordinateSpace(name: "scroll")
                        .onAppear {
                            // Set up the streak completion callback
                            dailyProgressVM.onDailyStreakCompleted = { streak, last7Days in
                                streakCount = streak
                                weeklyStreak = last7Days
                                showStreakFeedback = true
                            }
                        }
                    }

                    // Sticky Chat Box at the bottom with gradient fade
                    StickyChatBox()
                }
            }
            .navigationTitle(currentNavigationTitle)
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
            .fullScreenCover(isPresented: $showQuizView) {
                QuizView(vm: quizVM)
            }
            .fullScreenCover(isPresented: $showQuizResults) {
                QuizResultView(
                    score: quizVM.score,
                    total: quizVM.totalQuestions,
                    gradeText: quizVM.gradeText,
                    questions: quizVM.quizOfDay.questions,
                    questionStates: quizVM.questionStates,
                    onDone: { showQuizResults = false }
                )
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
        if let wisdom = dailyProgressVM.dailyWisdom {
            activities.append(wisdom)
        }
        return activities
    }
}

#Preview {
    TodayView()
}
