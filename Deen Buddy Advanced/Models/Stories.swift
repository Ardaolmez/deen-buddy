//
//  Stories.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

struct StorySection: Identifiable, Codable, Equatable {
    let id = UUID()
    let isBullets: Bool
    let heading: String
    let paragraphs: [String]
}

struct StoryArticle: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let intro: String
    let sections: [StorySection]
}

import Foundation

struct Caliph: Identifiable, Codable, Equatable {
    let id = UUID()
    let order: Int          // 1, 2, 3, 4...
    let name: String        // "Abu Bakr (RA)"
    let title: String       // "As-Siddiq, First Caliph"
    let stories: [StoryArticle]
}

