//
//  ReadingGoalTrackingView.swift
//  Deen Buddy Advanced
//
//  Interface for tracking reading or listening activity
//

import SwiftUI

enum TrackingMode {
    case reading
    case listening
}

struct ReadingGoalTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ReadingGoalViewModel
    let mode: TrackingMode

    @State private var versesCount: Int = 0
    @State private var minutesCount: Int = 0

    private var isTimeBased: Bool {
        viewModel.readingGoal?.goalType.isTimeBased ?? false
    }

    private var modeTitle: String {
        mode == .reading ? AppStrings.today.read : AppStrings.today.listen
    }

    private var modeIcon: String {
        mode == .reading ? "book.fill" : "headphones"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Mode Icon
                Image(systemName: modeIcon)
                    .font(.system(size: 60))
                    .foregroundColor(mode == .reading ? AppColors.Today.quranGoalButtonRead : AppColors.Today.quranGoalButtonListen)
                    .padding(.top, 40)

                // Current Position Display
                if let positionInfo = viewModel.currentPositionInfo {
                    VStack(spacing: 8) {
                        Text(AppStrings.today.current)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Today.quranGoalSectionHeader)

                        Text(positionInfo.displayText)
                            .font(.system(.title, design: .serif).weight(.semibold))
                            .foregroundColor(AppColors.Today.quranGoalPosition)
                    }
                }

                // Input Section
                VStack(spacing: 24) {
                    // Verses Counter (only for verse-based goals)
                    if !isTimeBased {
                        VStack(spacing: 12) {
                            Text(AppStrings.today.verses)
                                .font(.headline)
                                .foregroundColor(AppColors.Today.quranGoalTitle)

                            HStack(spacing: 20) {
                                Button {
                                    if versesCount > 0 {
                                        versesCount -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.Today.quranGoalButtonRead)
                                }

                                Text("\(versesCount)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(AppColors.Today.quranGoalPosition)
                                    .frame(minWidth: 100)

                                Button {
                                    versesCount += 1
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.Today.quranGoalButtonRead)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.Today.cardBackground)
                        )
                    }

                    // Minutes Counter (always shown)
                    VStack(spacing: 12) {
                        Text(AppStrings.today.minutes)
                            .font(.headline)
                            .foregroundColor(AppColors.Today.quranGoalTitle)

                        HStack(spacing: 20) {
                            Button {
                                if minutesCount > 0 {
                                    minutesCount -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(mode == .reading ? AppColors.Today.quranGoalButtonRead : AppColors.Today.quranGoalButtonListen)
                            }

                            Text("\(minutesCount)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(AppColors.Today.quranGoalPosition)
                                .frame(minWidth: 100)

                            Button {
                                minutesCount += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(mode == .reading ? AppColors.Today.quranGoalButtonRead : AppColors.Today.quranGoalButtonListen)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.Today.cardBackground)
                        )
                }
                .padding(.horizontal)

                Spacer()

                // Save Button
                Button {
                    saveActivity()
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (versesCount > 0 || minutesCount > 0) ?
                            (mode == .reading ? AppColors.Today.quranGoalButtonRead : AppColors.Today.quranGoalButtonListen) :
                            AppColors.Common.gray.opacity(0.3)
                        )
                        .foregroundColor(AppColors.Today.quranGoalButtonText)
                        .cornerRadius(12)
                }
                .disabled(versesCount == 0 && minutesCount == 0)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(modeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.today.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveActivity() {
        if mode == .reading {
            viewModel.recordReadingActivity(verses: versesCount, minutes: minutesCount)
        } else {
            viewModel.recordListeningActivity(verses: versesCount, minutes: minutesCount)
        }
        dismiss()
    }
}
