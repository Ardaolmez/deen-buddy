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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Streak Section
                    DailyStreakView(streakDays: $streakDays)
                        .padding(.horizontal)

                    // Daily Quran Verse
                    DailyVerseCard()
                        .padding(.horizontal)

                    // Daily Quiz Button
                    Button(action: {
                        showQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text(AppStrings.today.dailyQuiz)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.Today.dailyQuizButton)
                        .foregroundColor(AppColors.Today.dailyQuizText)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Daily Reading Goal
                    DailyReadingGoalCard()
                        .padding(.horizontal)

                    // Personalized Learning
                    PersonalizedLearningCard()
                        .padding(.horizontal)

                    // Chat Box
                    ChatBoxView()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .navigationTitle(AppStrings.today.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PrayerTimeCompactWidget()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Settings action
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(AppColors.Today.settingsIcon)
                    }
                }
            }
            .sheet(isPresented: $showQuiz) {
                QuizView()
            }
        }
    }
}

#Preview {
    TodayView()
}
