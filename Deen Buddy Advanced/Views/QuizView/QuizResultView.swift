//
//  QuizResultView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

import SwiftUI

struct QuizResultView: View {
    let score: Int
    let total: Int
    let gradeText: String
    let questions: [QuizQuestion]
    let questionStates: [QuizViewModel.QuestionAnswerState]
    let onDone: () -> Void

    private var percent: Double { total > 0 ? Double(score)/Double(total) : 0 }

    var body: some View {
        VStack(spacing: 16) {
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

            // Compact Card
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.Quiz.resultCardBackground)
                VStack(spacing: 12) {
                    // Circular ring - smaller
                    ProgressRing(progress: percent)
                        .frame(width: 120, height: 120)
                        .padding(.top, 12)

                    Text("\(score)/\(total)")
                        .font(.system(size: 22, weight: .bold, design: .serif))

                    Text(gradeText)
                        .font(.system(.title3, design: .serif))
                        .foregroundColor(.primary)
                        .padding(.bottom, 12)
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal)

            // Question Feedback List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                        QuestionFeedbackRow(
                            questionNumber: index + 1,
                            question: question,
                            state: questionStates[index]
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

// MARK: - Question Feedback Row
struct QuestionFeedbackRow: View {
    let questionNumber: Int
    let question: QuizQuestion
    let state: QuizViewModel.QuestionAnswerState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Question header
            HStack(spacing: 8) {
                // Number circle
                ZStack {
                    Circle()
                        .fill(state.isCorrect ? AppColors.Quiz.correctAnswerBackground : AppColors.Quiz.wrongAnswerBackground)
                        .frame(width: 28, height: 28)

                    Text("\(questionNumber)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.Quiz.buttonText)
                }

                // Question text
                Text(question.question)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Spacer()

                // Status icon
                Image(systemName: state.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(state.isCorrect ? AppColors.Quiz.correctAnswerBackground : AppColors.Quiz.wrongAnswerBackground)
            }

            // Answer details
            VStack(alignment: .leading, spacing: 6) {
                if case .incorrect(let selectedAnswer, let correctAnswer) = state {
                    // Your answer (incorrect)
                    HStack(spacing: 6) {
                        Text(AppStrings.quiz.yourAnswer + ":")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(selectedAnswer)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.Quiz.wrongAnswerBackground)
                    }

                    // Correct answer
                    HStack(spacing: 6) {
                        Text(AppStrings.quiz.correctAnswer + ":")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(correctAnswer)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.Quiz.correctAnswerBackground)
                    }
                } else if case .correct(let selectedAnswer) = state {
                    // Your answer (correct)
                    HStack(spacing: 6) {
                        Text(AppStrings.quiz.yourAnswer + ":")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(selectedAnswer)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.Quiz.correctAnswerBackground)
                    }
                }
            }
            .padding(.leading, 36)
        }
        .padding(12)
        .background(AppColors.Quiz.resultCardBackground)
        .cornerRadius(12)
    }
}

