// QuizView.swift
import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: QuizViewModel = .init()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress + score
                HStack {
                    Text(vm.progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(vm.score)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)

                if !vm.quizOfDay.title.isEmpty {
                    Text(vm.quizOfDay.title)
                        .font(.system(.headline, design: .serif))
                        .padding(.horizontal)
                }

                // Question & answers
                VStack(alignment: .leading, spacing: 16) {
                    Text(vm.currentQuestion.question)
                        .font(.system(.title2, design: .serif).weight(.semibold))
                        .padding(.horizontal)

                    ForEach(vm.currentQuestion.answers.indices, id: \.self) { idx in
                        AnswerRow(
                            text: vm.currentQuestion.answers[idx],
                            state: vm.stateForAnswer(at: idx),
                            isLocked: vm.isLocked
                        ) { vm.selectAnswer(idx) }
                    }
                }

                Spacer()

                // Next / Finish
                Button {
                    vm.next()     // will flip didFinish=true on last
                } label: {
                    Text(vm.isLastQuestion ? "See Results" : "Next Question")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.selectedIndex != nil ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(vm.selectedIndex == nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitle("Daily Quiz", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .fullScreenCover(isPresented: $vm.didFinish) {
            QuizResultView(
                score: vm.score,
                total: vm.totalQuestions,
                gradeText: vm.gradeText,
                onShare: { QuizShareSheet.present(text: "I scored \(vm.summaryLine) on Deen Buddy!") },
                onDone: { dismiss() },
                onRetry: { vm.restartSameQuiz() }
            )
        }
    }
}
