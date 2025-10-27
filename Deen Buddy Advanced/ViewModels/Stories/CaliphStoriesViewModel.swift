//
//  CaliphStoriesViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

final class CaliphStoriesViewModel: ObservableObject {
    @Published private(set) var caliphName: String
    @Published private(set) var caliphTitle: String
    @Published private(set) var stories: [StoryArticle]

    init(caliph: Caliph) {
        self.caliphName = caliph.name
        self.caliphTitle = caliph.title
        self.stories = caliph.stories
    }
}
