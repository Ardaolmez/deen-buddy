//
//  QuizViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/12/25.
//

// ViewModels/QuizViewModel.swift
import Foundation
import SwiftUI

final class QuizViewModel: ObservableObject {
    // Input data (could be injected)
    @Published private(set) var questions: [QuizQuestion] = [
        QuizQuestion(question: "How many Surahs are in the Quran?",
                     answers: ["114", "100", "120", "99"], correctIndex: 0),
        QuizQuestion(question: "Which Surah is known as the heart of the Quran?",
                     answers: ["Al-Fatiha", "Yasin", "Al-Baqarah", "Al-Ikhlas"], correctIndex: 1),
        QuizQuestion(question: "How many times is prayer (Salah) obligatory per day?",
                     answers: ["3", "4", "5", "6"], correctIndex: 2)
    ]

    // State
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var isLocked: Bool = false
    @Published private(set) var score: Int = 0

    var currentQuestion: QuizQuestion { questions[currentIndex] }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }
    var progressText: String { "Question \(currentIndex + 1) of \(questions.count)" }

    func selectAnswer(_ index: Int) {
        guard !isLocked else { return }               // don’t allow changes after pick
        selectedIndex = index
        isLocked = true
        if index == currentQuestion.correctIndex {
            score += 1
        }
    }

    func next() {
        guard isLocked else { return }
        if isLastQuestion { return }                  // caller can dismiss when finished
        currentIndex += 1
        selectedIndex = nil
        isLocked = false
    }

    // For per-answer styling
    enum AnswerState {
        case neutral
        case correctHighlight        // show as green
        case wrongHighlight          // show as red
    }

    func stateForAnswer(at index: Int) -> AnswerState {
        guard let chosen = selectedIndex else { return .neutral }
        let correct = currentQuestion.correctIndex
        if chosen == correct && index == correct {
            return .correctHighlight
        }
        if chosen != correct {
            if index == chosen { return .wrongHighlight }
            if index == correct { return .correctHighlight }
        }
        return .neutral
    }
}

