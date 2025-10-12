//
//  QuizQuestion.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/12/25.
//

import Foundation

// Models/QuizQuestion.swift

struct QuizQuestion: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answers: [String]
    let correctIndex: Int
}
