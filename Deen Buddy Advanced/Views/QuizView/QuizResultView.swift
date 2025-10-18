//
//  QuizResultView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

import SwiftUI

// QuizResultView.swift
import SwiftUI

struct QuizResultView: View {
    let score: Int
    let total: Int
    let gradeText: String
    let onShare: () -> Void
    let onDone: () -> Void
    let onRetry: () -> Void

    private var percent: Double { total > 0 ? Double(score)/Double(total) : 0 }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button {
                    onDone()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                Spacer()
                Text(AppStrings.quiz.navigationTitle)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                Spacer()
                // spacer to balance
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal)

            // Progress bar
            Capsule()
                .fill(AppColors.Quiz.progressBarBackground)
                .frame(height: 6)
                .overlay(
                    GeometryReader { geo in
                        Capsule()
                            .fill(AppColors.Quiz.progressBarFill)
                            .frame(width: geo.size.width * percent)
                    }
                )
                .padding(.horizontal)

            // Card
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppColors.Quiz.resultCardBackground)
                VStack(spacing: 18) {
                    // Circular ring
                    ProgressRing(progress: percent)
                        .frame(width: 160, height: 160)
                        .padding(.top, 16)

                    Text("\(score)/\(total)")
                        .font(.system(size: 24, weight: .bold, design: .serif))

                    Text(AppStrings.quiz.yourIman)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .padding(.top, 8)

                    Text(gradeText)
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Button {
                            onRetry()
                        } label: {
                            Label(AppStrings.quiz.retry, systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.Quiz.retryButtonBackground)
                                .foregroundColor(AppColors.Quiz.retryButtonText)
                                .cornerRadius(12)
                        }

                        Button {
                            onShare()
                        } label: {
                            Label(AppStrings.quiz.share, systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.Quiz.shareButtonBackground)
                                .foregroundColor(AppColors.Quiz.shareButtonText)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 8)
                }
                .padding()
            }
            .padding(.horizontal)

            // Footer note
            Text(AppStrings.quiz.tailoredQuizzes)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

