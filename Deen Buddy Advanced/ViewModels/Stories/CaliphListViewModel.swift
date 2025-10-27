//
//  CaliphListViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

final class CaliphListViewModel: ObservableObject {
    @Published private(set) var caliphs: [Caliph] = []

    private let repo: StoriesRepositoryType

    init(repo: StoriesRepositoryType = StoriesRepository.shared) {
        self.repo = repo
        load()
    }

    private func load() {
        caliphs = repo.allCaliphs()
            .sorted { $0.order < $1.order }
    }
}
