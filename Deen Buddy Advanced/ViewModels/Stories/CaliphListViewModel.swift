//
//  CaliphListViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Combine
import Foundation

final class CaliphListViewModel: ObservableObject {
    @Published private(set) var items: [CaliphListItem] = []
    @Published private(set) var nextUnlockDate: Date?

    private let repo: StoriesRepositoryType
    private let progressStore: CaliphStoriesProgressStoreType
    private let useUnlockTimer: Bool
    private var cancellables = Set<AnyCancellable>()

    init(repo: StoriesRepositoryType = StoriesRepository.shared,
         progressStore: CaliphStoriesProgressStoreType = CaliphStoriesProgressStore.shared,
         useUnlockTimer: Bool = false) {
        self.repo = repo
        self.progressStore = progressStore
        self.useUnlockTimer = useUnlockTimer
        load()

        NotificationCenter.default.publisher(for: CaliphStoriesProgressStore.progressDidChangeNotification)
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    var usesUnlockTimer: Bool { useUnlockTimer }

    func refresh() {
        load()
    }

    private func load(date: Date = Date()) {
        let orderedCaliphs = repo.allCaliphs()
            .sorted { $0.order < $1.order }

        let totalStories = orderedCaliphs.reduce(0) { $0 + $1.stories.count }
        let snapshot = progressStore.snapshot(totalStories: totalStories, referenceDate: date)
        let maxUnlockedIndex = snapshot.unlockedCount > 0 ? snapshot.unlockedCount - 1 : -1
        var runningIndex = 0

        items = orderedCaliphs.map { caliph in
            defer { runningIndex += caliph.stories.count }
            let storyCount = caliph.stories.count
            let startIndex = runningIndex
            let endIndex = runningIndex + max(storyCount - 1, 0)

            let isUnlocked: Bool
            if storyCount == 0 {
                isUnlocked = true
            } else {
                isUnlocked = maxUnlockedIndex >= startIndex
            }

            let lastCompletedIndex = snapshot.lastCompletedIndex ?? -1
            let isCompleted = storyCount > 0 ? lastCompletedIndex >= endIndex : false

            return CaliphListItem(caliph: caliph, isLocked: !isUnlocked, isCompleted: isCompleted)
        }

        nextUnlockDate = useUnlockTimer ? snapshot.nextUnlockDate : nil
    }

    struct CaliphListItem: Identifiable {
        let caliph: Caliph
        let isLocked: Bool
        let isCompleted: Bool

        var id: UUID { caliph.id }
    }
}
