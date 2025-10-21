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
    let surah: String?
    let verse: Int?
    let explanation: String?


    init(id: UUID = UUID(), question: String, answers: [String], correctIndex: Int, surah: String? = nil, verse: Int? = nil, explanation: String? = nil) {
        self.id = id
        self.question = question
        self.answers = answers
        self.correctIndex = correctIndex
        self.surah = surah
        self.verse = verse
        self.explanation = explanation
    }

    // Custom coding keys to handle UUID generation for decoded objects
    enum CodingKeys: String, CodingKey {
        case question, answers, correctIndex, surah, verse, explanation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.question = try container.decode(String.self, forKey: .question)
        self.answers = try container.decode([String].self, forKey: .answers)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
        self.surah = try? container.decode(String.self, forKey: .surah)
        self.verse = try? container.decode(Int.self, forKey: .verse)
        self.explanation = try? container.decode(String.self, forKey: .explanation)
    }
}
