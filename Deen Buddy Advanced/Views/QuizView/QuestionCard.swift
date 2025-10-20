//
//  QuestionCard.swift
//  Deen Buddy Advanced
//
//  Quiz question card with conditional explanation display
//

import SwiftUI

struct QuestionCard: View {
    let question: String
    let showExplanation: Bool
    let isCorrect: Bool?
    let correctAnswer: String?
    let explanation: String?
    let reference: String?
    let onReferenceClick: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question text
            Text(question)
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundColor(AppColors.Quiz.explanationText)
                .fixedSize(horizontal: false, vertical: true)

            // Show feedback only when explanation should be shown
            if showExplanation {
                Divider()

                // Correct/Incorrect header (text only, no icons)
                Text(isCorrect == true ? AppStrings.quiz.correct : AppStrings.quiz.incorrect)
                    .font(.headline)
                    .foregroundColor(isCorrect == true ? AppColors.Quiz.explanationCorrectHeader : AppColors.Quiz.explanationIncorrectHeader)

                // Show correct answer if user was wrong
                if isCorrect == false, let correctAns = correctAnswer {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.quiz.correctAnswerIs)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Quiz.explanationReference)
                        Text(correctAns)
                            .font(.body.weight(.semibold))
                            .foregroundColor(AppColors.Quiz.explanationCorrectHeader)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Explanation
                if let exp = explanation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AppStrings.quiz.explanation)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.Quiz.explanationReference)
                        Text(exp)
                            .font(.body)
                            .foregroundColor(AppColors.Quiz.explanationText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Reference (Surah:Verse) - clickable
                if let ref = reference {
                    HStack(spacing: 4) {
                        Text(AppStrings.quiz.reference)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Quiz.explanationReference)

                        Button {
                            onReferenceClick?()
                        } label: {
                            Text(ref)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColors.Quiz.referenceLink)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.Quiz.explanationCardBackground)
        )
        .padding(.horizontal)
    }
}
