//
//  QuizView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestion = 0
    @State private var selectedAnswer: Int? = nil
    @State private var score = 0

    let questions = [
        QuizQuestion(
            question: "How many Surahs are in the Quran?",
            answers: ["114", "100", "120", "99"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which Surah is known as the heart of the Quran?",
            answers: ["Al-Fatiha", "Yasin", "Al-Baqarah", "Al-Ikhlas"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "How many times is prayer (Salah) obligatory per day?",
            answers: ["3", "4", "5", "6"],
            correctAnswer: 2
        )
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress
                HStack {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)

                // Question
                VStack(alignment: .leading, spacing: 16) {
                    Text(questions[currentQuestion].question)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()

                    // Answers
                    ForEach(0..<questions[currentQuestion].answers.count, id: \.self) { index in
                        Button(action: {
                            selectedAnswer = index
                        }) {
                            HStack {
                                Text(questions[currentQuestion].answers[index])
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedAnswer == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedAnswer == index ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Next Button
                Button(action: {
                    if selectedAnswer == questions[currentQuestion].correctAnswer {
                        score += 1
                    }

                    if currentQuestion < questions.count - 1 {
                        currentQuestion += 1
                        selectedAnswer = nil
                    } else {
                        dismiss()
                    }
                }) {
                    Text(currentQuestion < questions.count - 1 ? "Next Question" : "Finish Quiz")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAnswer != nil ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedAnswer == nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Daily Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuizQuestion {
    let question: String
    let answers: [String]
    let correctAnswer: Int
}

#Preview {
    QuizView()
}
