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
        VStack(spacing: 16) {
            // Title and subtitle - left aligned
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(TodayStrings.dailyQuizLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .tracking(0.5)

                    Spacer()
                }
                

                Text("Learn something new every day")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 16)
            // Question circles
            HStack(spacing: 18) {
                ForEach(0..<min(5, quizViewModel.questionStates.count), id: \.self) { index in
                    SimpleQuestionCircle(
                        number: index + 1,
                        state: quizViewModel.questionStates[index]
                    )
                    .onTapGesture {
                        quizViewModel.navigateToQuestion(index)
                        showQuizView = true
                    }
                }
            }

            // Button under circles
            Button(action: {
                handleButtonTap()
            }) {
                Text(buttonText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.Today.brandGreen)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(quizViewModel.totalQuestions == 0)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.Quran.papyrusSquare)
                .shadow(color: AppColors.Prayers.prayerGreen, radius: 4, x: 0, y: 2)
        )
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
            // Navigate to first question to review feedback
            quizViewModel.navigateToQuestion(0)
            showQuizView = true
        } else {
            // Open next unanswered question in QuizView
            if let nextIndex = quizViewModel.nextUnansweredQuestionIndex() {
                quizViewModel.navigateToQuestion(nextIndex)
                showQuizView = true
            }
        }
    }
}

// MARK: - Simple Components

struct SimpleQuestionCircle: View {
    let number: Int
    let state: QuizViewModel.QuestionAnswerState

    var body: some View {
        ZStack {
            // Circle background
            Circle()
                .fill(fillColor)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: borderWidth)
                )

            // Always show number - white when answered, gray when unanswered
            Text("\(number)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textColor)
        }
    }

    private var fillColor: Color {
        switch state {
        case .unanswered:
            return .white
        case .correct:
            return AppColors.Today.quizCircleCorrect
        case .incorrect:
            return AppColors.Today.quizCircleIncorrect
        }
    }

    private var borderColor: Color {
        switch state {
        case .unanswered:
            return .black.opacity(0.6)
        case .correct:
            return AppColors.Today.quizCircleCorrect
        case .incorrect:
            return AppColors.Today.quizCircleIncorrect
        }
    }

    private var borderWidth: CGFloat {
        state.isAnswered ? 0 : 2
    }

    private var textColor: Color {
        switch state {
        case .unanswered:
            return .primary.opacity(0.6)
        case .correct, .incorrect:
            return .white
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
