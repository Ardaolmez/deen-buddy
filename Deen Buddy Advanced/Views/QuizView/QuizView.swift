// Views/QuizView.swift
import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = QuizViewModel()

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

                // Question + Answers
                VStack(alignment: .leading, spacing: 16) {
                    Text(vm.currentQuestion.question)
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal)

                    ForEach(vm.currentQuestion.answers.indices, id: \.self) { idx in
                        AnswerRow(
                            text: vm.currentQuestion.answers[idx],
                            state: vm.stateForAnswer(at: idx),
                            isLocked: vm.isLocked
                        ) {
                            vm.selectAnswer(idx)
                        }
                    }
                }

                Spacer()

                // Next / Finish
                Button {
                    if vm.isLastQuestion {
                        dismiss()
                    } else {
                        vm.next()
                    }
                } label: {
                    Text(vm.isLastQuestion ? "Finish Quiz" : "Next Question")
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
    }
}
