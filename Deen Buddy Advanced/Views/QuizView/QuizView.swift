// QuizView.swift
import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: QuizViewModel = .init()
    @State private var showAnswers: Bool = true
    @State private var showExplanation: Bool = false
    @State private var showVersePopup: Bool = false

    private var progress: Double {
        guard vm.totalQuestions > 0 else { return 0 }
        return Double(vm.currentIndex) / Double(vm.totalQuestions)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Custom Header (like QuizResultView)
            HStack {
                Button {
                    dismiss()
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
                // Spacer to balance
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal)

            // Progress bar (like QuizResultView)
            Capsule()
                .fill(AppColors.Quiz.progressBarBackground)
                .frame(height: 6)
                .overlay(
                    GeometryReader { geo in
                        Capsule()
                            .fill(AppColors.Quiz.progressBarFill)
                            .frame(width: geo.size.width * progress)
                    }
                )
                .padding(.horizontal)

            // Question Card with conditional explanation
            QuestionCard(
                question: vm.currentQuestion.question,
                showExplanation: showExplanation,
                isCorrect: vm.isCorrectAnswer,
                correctAnswer: vm.isCorrectAnswer == false ? vm.currentQuestion.answers[vm.currentQuestion.correctIndex] : nil,
                explanation: vm.currentQuestion.explanation,
                reference: vm.verseReference,
                onReferenceClick: {
                    showVersePopup = true
                }
            )

            // Verse display (shown after explanation appears)
            if showExplanation, let verse = vm.fetchVerseForCurrentQuestion() {
                VerseDisplay(verse: verse)
            }

            // Answer list (vertical) - shown only when not answered
            if showAnswers {
                VStack(spacing: 12) {
                    ForEach(vm.currentQuestion.answers.indices, id: \.self) { idx in
                        AnswerRow(
                            text: vm.currentQuestion.answers[idx],
                            state: vm.stateForAnswer(at: idx),
                            isLocked: vm.isLocked
                        ) {
                            vm.selectAnswer(idx)
                            // Hide answers and show explanation after 1 second
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    showAnswers = false
                                    showExplanation = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Next / Finish (only show after explanation appears)
            if showExplanation {
                Button {
                    vm.next()
                    // Reset states for next question
                    showAnswers = true
                    showExplanation = false
                } label: {
                    Text(vm.isLastQuestion ? AppStrings.quiz.seeResults : AppStrings.quiz.nextQuestion)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.Quiz.nextButtonActive)
                        .foregroundColor(AppColors.Quiz.buttonText)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .fullScreenCover(isPresented: $vm.didFinish) {
            QuizResultView(
                score: vm.score,
                total: vm.totalQuestions,
                gradeText: vm.gradeText,
                onShare: { QuizShareSheet.present(text: String(format: AppStrings.quiz.shareText, vm.summaryLine)) },
                onDone: { dismiss() },
                onRetry: { vm.restartSameQuiz() }
            )
        }
        .sheet(isPresented: $showVersePopup) {
            if let surahName = vm.currentQuestion.surah,
               let verseNum = vm.currentQuestion.verse {
                VersePopupView(surahName: surahName, verseNumber: verseNum)
            }
        }
    }
}
