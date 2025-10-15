//
//  QuizQuestion.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/12/25.
//

import Foundation

// Models/QuizQuestion.swift

struct QuizQuestion: Identifiable, Equatable, Codable {
    let id: UUID
    let question: String
    let answers: [String]
    let correctIndex: Int

    init(id: UUID = UUID(), question: String, answers: [String], correctIndex: Int) {
        self.id = id
        self.question = question
        self.answers = answers
        self.correctIndex = correctIndex
    }

    // Custom coding keys to handle UUID generation for decoded objects
    enum CodingKeys: String, CodingKey {
        case question, answers, correctIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.question = try container.decode(String.self, forKey: .question)
        self.answers = try container.decode([String].self, forKey: .answers)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
    }
}
