// QuizView.swift
import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: QuizViewModel = .init()
    @State private var showAnswers: Bool = false
    @State private var showExplanation: Bool = false
    @State private var showVersePopup: Bool = false
    @State private var isQuestionStreaming: Bool = true
    @State private var visibleAnswerCount: Int = 0
    @State private var answerRevealTask: Task<Void, Never>? = nil
    private let answerRevealStepDelay: Double = 0.14

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
                },
                isStreaming: isQuestionStreaming,
                onStreamingComplete: {
                    isQuestionStreaming = false
                    guard !showExplanation else { return }
                    visibleAnswerCount = 0
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showAnswers = true
                    }
                    startAnswerReveal()
                }
            )

            // Verse display (shown after explanation appears)
            if showExplanation, let verse = vm.fetchVerseForCurrentQuestion() {
                VerseDisplay(verse: verse)
            }

            // Answer list (vertical) - shown only when not answered
            if showAnswers {
                let answers = vm.currentQuestion.answers
                VStack(spacing: 12) {
                    ForEach(0..<min(visibleAnswerCount, answers.count), id: \.self) { idx in
                        AnswerRow(
                            text: answers[idx],
                            state: vm.stateForAnswer(at: idx),
                            isLocked: vm.isLocked
                        ) {
                            guard !vm.isLocked else { return }
                            vm.selectAnswer(idx)
                            answerRevealTask?.cancel()
                            answerRevealTask = nil
                            // Hide answers and show explanation after 1 second
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    showAnswers = false
                                    visibleAnswerCount = 0
                                    showExplanation = true
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Next / Finish (only show after explanation appears)
            if showExplanation {
                Button {
                    let isLastQuestion = vm.isLastQuestion
                    if !isLastQuestion {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            prepareForNewQuestion()
                        }
                    }
                    vm.next()
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
        .onChange(of: vm.currentIndex) { _ in
            prepareForNewQuestion()
        }
        .onChange(of: vm.didFinish) { finished in
            if !finished {
                prepareForNewQuestion()
            }
        }
        .onDisappear {
            answerRevealTask?.cancel()
            answerRevealTask = nil
        }
    }
}

private extension QuizView {
    func prepareForNewQuestion(resetExplanation: Bool = true) {
        answerRevealTask?.cancel()
        answerRevealTask = nil
        if resetExplanation {
            showExplanation = false
        }
        showAnswers = false
        visibleAnswerCount = 0
        isQuestionStreaming = true
    }

    func startAnswerReveal() {
        answerRevealTask?.cancel()
        answerRevealTask = nil

        let answers = vm.currentQuestion.answers
        guard !answers.isEmpty else { return }
        let questionIndex = vm.currentIndex
        let delay = UInt64(answerRevealStepDelay * 1_000_000_000)

        visibleAnswerCount = 0

        answerRevealTask = Task {
            for idx in answers.indices {
                guard !Task.isCancelled else {
                    await MainActor.run {
                        answerRevealTask = nil
                    }
                    return
                }

                try? await Task.sleep(nanoseconds: delay)

                guard !Task.isCancelled else {
                    await MainActor.run {
                        answerRevealTask = nil
                    }
                    return
                }

                let didReveal = await MainActor.run { () -> Bool in
                    guard vm.currentIndex == questionIndex, showAnswers else {
                        return false
                    }
                    withAnimation(.easeOut(duration: 0.25)) {
                        visibleAnswerCount = idx + 1
                    }
                    return true
                }

                guard didReveal else {
                    await MainActor.run {
                        answerRevealTask = nil
                    }
                    return
                }
            }

            await MainActor.run {
                answerRevealTask = nil
            }
        }
    }
}
