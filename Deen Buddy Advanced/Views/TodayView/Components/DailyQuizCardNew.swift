//
//  DailyQuizCardNew.swift
//  Deen Buddy Advanced
//
//  New daily quiz card with non-linear question navigation
//

import SwiftUI

struct DailyQuizCardNew: View {
    @ObservedObject var quizViewModel: QuizViewModel
    @Binding var selectedQuestionIndex: Int?
    @Binding var showQuizView: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text(TodayStrings.dailyQuizLabel)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.Today.activityCardTitle)
                .tracking(1.0)

            // Question circles with numbers
            HStack(spacing: 20) {
                ForEach(0..<min(5, quizViewModel.questionStates.count), id: \.self) { index in
                    QuestionCircleView(
                        number: index + 1,
                        state: quizViewModel.questionStates[index]
                    )
                    .onTapGesture {
                        // Navigate to QuizView at this question index
                        quizViewModel.navigateToQuestion(index)
                        showQuizView = true
                    }
                }
            }

            // Action button
            Button(action: {
                handleButtonTap()
            }) {
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Today.dailyQuizText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.Today.dailyQuizButton)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }

    private var buttonText: String {
        if quizViewModel.allQuestionsAnswered {
            return TodayStrings.dailyQuizReview
        } else if quizViewModel.answeredQuestionsCount > 0 {
            return TodayStrings.dailyQuizContinue
        } else {
            return TodayStrings.dailyQuizStart
        }
    }

    private func handleButtonTap() {
        if quizViewModel.allQuestionsAnswered {
            // Show results
            quizViewModel.didFinish = true
        } else {
            // Open next unanswered question in QuizView
            if let nextIndex = quizViewModel.nextUnansweredQuestionIndex() {
                quizViewModel.navigateToQuestion(nextIndex)
                showQuizView = true
            }
        }
    }
}

struct QuestionCircleView: View {
    let number: Int
    let state: QuizViewModel.QuestionAnswerState

    var body: some View {
        ZStack {
            // Circle background
            Circle()
                .fill(fillColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: borderWidth)
                )

            // Content (number or icon)
            if state.isAnswered {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.Today.quizCircleIcon)
            } else {
                // Number above circle
                VStack(spacing: 2) {
                    Text("\(number)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.Today.quizCircleNumber)
                }
            }
        }
        .overlay(
            // Number positioned above when answered
            state.isAnswered ?
            Text("\(number)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.Today.quizCircleNumber)
                .offset(y: -35)
            : nil
        )
    }

    private var fillColor: Color {
        switch state {
        case .unanswered:
            return AppColors.Today.quizCircleUnanswered
        case .correct:
            return AppColors.Today.quizCircleCorrect
        case .incorrect:
            return AppColors.Today.quizCircleIncorrect
        }
    }

    private var borderColor: Color {
        switch state {
        case .unanswered:
            return AppColors.Today.quizCircleBorder
        case .correct:
            return AppColors.Today.quizCircleCorrect
        case .incorrect:
            return AppColors.Today.quizCircleIncorrect
        }
    }

    private var borderWidth: CGFloat {
        state.isAnswered ? 0 : 2
    }

    private var iconName: String {
        switch state {
        case .correct:
            return "checkmark"
        case .incorrect:
            return "xmark"
        default:
            return ""
        }
    }
}

#Preview {
    VStack {
        DailyQuizCardNew(
            quizViewModel: QuizViewModel(),
            selectedQuestionIndex: .constant(nil),
            showQuizView: .constant(false)
        )
    }
    .background(AppColors.Today.papyrusBackground)
}
