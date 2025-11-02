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

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily Streak Section
                     //   DailyStreakView(streakDays: $streakDays)
                       //     .padding(.horizontal, 20)

                        // Daily Quran Verse
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
//                            .padding(.horizontal, 20)

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
        }
    }
}

#Preview {
    TodayView()
}
