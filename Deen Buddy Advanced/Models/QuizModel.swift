//
//  QuizModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/13/25.
//
import Foundation

struct QuizModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let questions: [QuizQuestion]
}
