//
//  CaliphStoriesViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Combine
import Foundation

final class CaliphStoriesViewModel: ObservableObject {
    @Published private(set) var caliphName: String
    @Published private(set) var caliphTitle: String
    @Published private(set) var storyItems: [StoryItem] = []
    @Published private(set) var nextUnlockDate: Date?

    let totalStories: Int

    private let caliph: Caliph
    private let repo: StoriesRepositoryType
    private let progressStore: CaliphStoriesProgressStoreType
    private let useUnlockTimer: Bool
    private let globalStartIndex: Int
    private var cancellables = Set<AnyCancellable>()

    init(caliph: Caliph,
         repo: StoriesRepositoryType = StoriesRepository.shared,
         progressStore: CaliphStoriesProgressStoreType = CaliphStoriesProgressStore.shared,
         useUnlockTimer: Bool = false) {
        self.caliph = caliph
        self.caliphName = caliph.name
        self.caliphTitle = caliph.title
        self.repo = repo
        self.progressStore = progressStore
        self.useUnlockTimer = useUnlockTimer

        let orderedCaliphs = repo.allCaliphs()
            .sorted { $0.order < $1.order }

        let (startIndex, total) = CaliphStoriesViewModel.resolveIndices(for: caliph, within: orderedCaliphs)
        self.globalStartIndex = startIndex
        self.totalStories = total

        refresh()

        NotificationCenter.default.publisher(for: CaliphStoriesProgressStore.progressDidChangeNotification)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    var usesUnlockTimer: Bool { useUnlockTimer }

    func refresh(date: Date = Date()) {
        let snapshot = progressStore.snapshot(totalStories: totalStories, referenceDate: date)
        nextUnlockDate = useUnlockTimer ? snapshot.nextUnlockDate : nil

        storyItems = caliph.stories.enumerated().map { offset, article in
            let globalIndex = globalStartIndex + offset
            let isUnlocked = globalIndex < snapshot.unlockedCount
            let isCompleted = (snapshot.lastCompletedIndex ?? -1) >= globalIndex
            let isNextToUnlock = !isUnlocked && globalIndex == snapshot.unlockedCount

            return StoryItem(article: article,
                             localIndex: offset,
                             globalIndex: globalIndex,
                             isUnlocked: isUnlocked,
                             isCompleted: isCompleted,
                             isNextToUnlock: isNextToUnlock)
        }
    }

    func markStoryCompleted(_ item: StoryItem, date: Date = Date()) {
        progressStore.markStoryCompleted(globalIndex: item.globalIndex,
                                         totalStories: totalStories,
                                         referenceDate: date,
                                         useUnlockTimer: useUnlockTimer)
    }

    private static func resolveIndices(for target: Caliph, within orderedCaliphs: [Caliph]) -> (start: Int, total: Int) {
        let total = orderedCaliphs.reduce(0) { $0 + $1.stories.count }
        var startIndex = 0

        for caliph in orderedCaliphs {
            if caliph.order == target.order && caliph.name == target.name {
                break
            }
            startIndex += caliph.stories.count
        }

        return (startIndex, total)
    }

    struct StoryItem: Identifiable {
        let article: StoryArticle
        let localIndex: Int
        let globalIndex: Int
        let isUnlocked: Bool
        let isCompleted: Bool
        let isNextToUnlock: Bool

        var id: UUID { article.id }
    }
}
