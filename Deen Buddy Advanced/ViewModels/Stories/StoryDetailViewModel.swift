//
//  StoryDetailViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Combine
import Foundation

final class StoryDetailViewModel: ObservableObject {
    @Published private(set) var story: StoryArticle
    @Published private(set) var isUnlocked: Bool = false
    @Published private(set) var isCompleted: Bool = false
    @Published private(set) var canMarkAsRead: Bool = false
    @Published private(set) var nextUnlockDate: Date?

    private let globalIndex: Int
    private let totalStories: Int
    private let progressStore: CaliphStoriesProgressStoreType
    private var cancellables = Set<AnyCancellable>()

    init(story: StoryArticle,
         globalIndex: Int,
         totalStories: Int,
         progressStore: CaliphStoriesProgressStoreType = CaliphStoriesProgressStore.shared) {
        self.story = story
        self.globalIndex = globalIndex
        self.totalStories = totalStories
        self.progressStore = progressStore

        refresh()

        NotificationCenter.default.publisher(for: CaliphStoriesProgressStore.progressDidChangeNotification)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    func refresh(date: Date = Date()) {
        let snapshot = progressStore.snapshot(totalStories: totalStories, referenceDate: date)
        updateState(using: snapshot)
    }

    func markAsRead(date: Date = Date()) {
        guard canMarkAsRead else { return }
        progressStore.markStoryCompleted(globalIndex: globalIndex,
                                         totalStories: totalStories,
                                         referenceDate: date)
    }

    private func updateState(using snapshot: CaliphStoriesProgressSnapshot) {
        let unlockedCount = snapshot.unlockedCount
        isUnlocked = globalIndex < unlockedCount
        let lastCompleted = snapshot.lastCompletedIndex ?? -1
        isCompleted = lastCompleted >= globalIndex
        canMarkAsRead = isUnlocked && !isCompleted && globalIndex == unlockedCount - 1
        nextUnlockDate = snapshot.nextUnlockDate
    }
}
