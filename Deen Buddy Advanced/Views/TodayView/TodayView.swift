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
    @StateObject private var prayersVM = PrayersViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Streak Section
                    DailyStreakView(streakDays: $streakDays)
                        .padding(.horizontal, 20)

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
                    DailyReadGoalCard()
                        .padding(.horizontal, 20)

                    // Chat Box
                    ChatBoxView()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
            .navigationTitle(AppStrings.today.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PrayerTimeCompact(nextPrayer: prayersVM.nextPrayer)
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
            .fullScreenCover(isPresented: $showQuiz) {
                QuizView()
            }
        }
    }
}

#Preview {
    TodayView()
}
