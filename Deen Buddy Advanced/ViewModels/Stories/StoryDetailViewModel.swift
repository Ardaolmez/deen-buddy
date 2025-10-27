//
//  StoryDetailViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

final class StoryDetailViewModel: ObservableObject {
    @Published private(set) var story: StoryArticle

    init(story: StoryArticle) {
        self.story = story
    }
}
