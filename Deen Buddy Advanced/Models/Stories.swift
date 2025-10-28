//
//  Stories.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

struct StorySection: Identifiable, Codable, Equatable {
    let id: UUID
    let isBullets: Bool
    let heading: String
    let paragraphs: [String]

    init(id: UUID = UUID(), isBullets: Bool, heading: String, paragraphs: [String]) {
        self.id = id
        self.isBullets = isBullets
        self.heading = heading
        self.paragraphs = paragraphs
    }

    private enum CodingKeys: String, CodingKey {
        case isBullets
        case heading
        case paragraphs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.isBullets = try container.decode(Bool.self, forKey: .isBullets)
        self.heading = try container.decode(String.self, forKey: .heading)
        self.paragraphs = try container.decode([String].self, forKey: .paragraphs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isBullets, forKey: .isBullets)
        try container.encode(heading, forKey: .heading)
        try container.encode(paragraphs, forKey: .paragraphs)
    }
}

struct StoryArticle: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let intro: String
    let sections: [StorySection]

    init(id: UUID = UUID(), title: String, subtitle: String, intro: String, sections: [StorySection]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.intro = intro
        self.sections = sections
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case intro
        case sections
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.intro = try container.decode(String.self, forKey: .intro)
        self.sections = try container.decode([StorySection].self, forKey: .sections)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(intro, forKey: .intro)
        try container.encode(sections, forKey: .sections)
    }
}

struct Caliph: Identifiable, Codable, Equatable {
    let id: UUID
    let order: Int          // 1, 2, 3, 4...
    let name: String        // "Abu Bakr (RA)"
    let title: String       // "As-Siddiq, First Caliph"
    let stories: [StoryArticle]

    init(id: UUID = UUID(), order: Int, name: String, title: String, stories: [StoryArticle]) {
        self.id = id
        self.order = order
        self.name = name
        self.title = title
        self.stories = stories
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case name
        case title
        case stories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.order = try container.decode(Int.self, forKey: .order)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .title)
        self.stories = try container.decode([StoryArticle].self, forKey: .stories)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(order, forKey: .order)
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(stories, forKey: .stories)
    }
}
