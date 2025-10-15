//
//  QuizModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/13/25.
//
import Foundation

struct QuizModel: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let questions: [QuizQuestion]

    init(id: UUID = UUID(), title: String, questions: [QuizQuestion]) {
        self.id = id
        self.title = title
        self.questions = questions
    }

    // Custom coding keys to handle UUID generation for decoded objects
    enum CodingKeys: String, CodingKey {
        case title, questions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.questions = try container.decode([QuizQuestion].self, forKey: .questions)
    }
}
