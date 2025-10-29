//
//  CaliphStoriesProgressStore.swift
//  Deen Buddy Advanced
//
//  Created by AI on 10/27/25.
//

import Foundation

protocol CaliphStoriesProgressStoreType {
    var unlockInterval: TimeInterval { get }
    func snapshot(totalStories: Int, referenceDate: Date) -> CaliphStoriesProgressSnapshot
    func markStoryCompleted(globalIndex: Int, totalStories: Int, referenceDate: Date)
}

extension CaliphStoriesProgressStoreType {
    func snapshot(totalStories: Int, referenceDate: Date = Date()) -> CaliphStoriesProgressSnapshot {
        snapshot(totalStories: totalStories, referenceDate: referenceDate)
    }

    func markStoryCompleted(globalIndex: Int, totalStories: Int, referenceDate: Date = Date()) {
        markStoryCompleted(globalIndex: globalIndex, totalStories: totalStories, referenceDate: referenceDate)
    }
}

struct CaliphStoriesProgressSnapshot {
    let unlockedCount: Int
    let lastCompletedIndex: Int?
    let lastCompletionDate: Date?
    let nextUnlockDate: Date?
}

final class CaliphStoriesProgressStore: CaliphStoriesProgressStoreType {
    static let shared = CaliphStoriesProgressStore()
    static let progressDidChangeNotification = Notification.Name("CaliphStoriesProgressDidChange")

    let unlockInterval: TimeInterval

    private let userDefaults: UserDefaults
    private let storageKey = "CaliphStoriesProgressState"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.deenbuddy.caliphs.progress")

    private struct ProgressState: Codable {
        var unlockedCount: Int
        var lastCompletedIndex: Int?
        var lastCompletionDate: Date?
    }

    private var state: ProgressState

    init(userDefaults: UserDefaults = .standard, unlockInterval: TimeInterval = 5 * 60) {
        self.userDefaults = userDefaults
        self.unlockInterval = unlockInterval
        self.state = Self.loadState(from: userDefaults, key: storageKey, decoder: decoder)
        sanitizeState(totalStories: nil)
    }

    func snapshot(totalStories: Int, referenceDate: Date) -> CaliphStoriesProgressSnapshot {
        return queue.sync {
            let didChange = refreshUnlockIfNeeded(totalStories: totalStories, referenceDate: referenceDate)
            sanitizeState(totalStories: totalStories)
            if didChange {
                saveStateLocked()
            }
            let sanitized = state
            let snapshot = CaliphStoriesProgressSnapshot(
                unlockedCount: sanitized.unlockedCount,
                lastCompletedIndex: sanitized.lastCompletedIndex,
                lastCompletionDate: sanitized.lastCompletionDate,
                nextUnlockDate: nextUnlockDate(for: sanitized, totalStories: totalStories)
            )
            if didChange {
                notifyChange()
            }
            return snapshot
        }
    }

    func markStoryCompleted(globalIndex: Int, totalStories: Int, referenceDate: Date) {
        var shouldNotify = false
        queue.sync {
            let unlockedChanged = refreshUnlockIfNeeded(totalStories: totalStories, referenceDate: referenceDate)
            var mutated = false

            guard totalStories > 0 else {
                sanitizeState(totalStories: 0)
                if unlockedChanged {
                    saveStateLocked()
                    shouldNotify = true
                }
                return
            }

            sanitizeState(totalStories: totalStories)

            guard globalIndex < state.unlockedCount else {
                if unlockedChanged {
                    saveStateLocked()
                    shouldNotify = true
                }
                return
            }

            let previousCompleted = state.lastCompletedIndex ?? -1
            if globalIndex >= previousCompleted {
                if state.lastCompletedIndex != globalIndex {
                    state.lastCompletedIndex = globalIndex
                    mutated = true
                }
                if state.lastCompletionDate != referenceDate {
                    state.lastCompletionDate = referenceDate
                    mutated = true
                }
            }

            if mutated || unlockedChanged {
                sanitizeState(totalStories: totalStories)
                saveStateLocked()
                shouldNotify = true
            }
        }

        if shouldNotify {
            notifyChange()
        }
    }

    // MARK: - Private

    private static func loadState(from defaults: UserDefaults, key: String, decoder: JSONDecoder) -> ProgressState {
        guard let data = defaults.data(forKey: key),
              let loaded = try? decoder.decode(ProgressState.self, from: data) else {
            return ProgressState(unlockedCount: 1, lastCompletedIndex: nil, lastCompletionDate: nil)
        }
        return loaded
    }

    private func refreshUnlockIfNeeded(totalStories: Int, referenceDate: Date) -> Bool {
        guard totalStories > 0,
              let lastCompletedIndex = state.lastCompletedIndex,
              let lastCompletionDate = state.lastCompletionDate else {
            return false
        }

        let nextIndex = lastCompletedIndex + 1
        guard nextIndex < totalStories else {
            return false
        }

        guard state.unlockedCount <= nextIndex else {
            return false
        }

        let elapsed = referenceDate.timeIntervalSince(lastCompletionDate)
        guard elapsed >= unlockInterval else {
            return false
        }

        state.unlockedCount = min(totalStories, nextIndex + 1)
        return true
    }

    private func sanitizeState(totalStories: Int?) {
        if let totalStories {
            let minimumUnlocked = totalStories > 0 ? 1 : 0
            if state.unlockedCount < minimumUnlocked {
                state.unlockedCount = minimumUnlocked
            }
            if state.unlockedCount > totalStories {
                state.unlockedCount = totalStories
            }
            if let lastCompleted = state.lastCompletedIndex, lastCompleted >= totalStories {
                state.lastCompletedIndex = totalStories > 0 ? totalStories - 1 : nil
            }
        } else {
            if state.unlockedCount < 1 {
                state.unlockedCount = 1
            }
        }
    }

    private func saveStateLocked() {
        if let data = try? encoder.encode(state) {
            userDefaults.set(data, forKey: storageKey)
        }
    }

    private func notifyChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.progressDidChangeNotification, object: nil)
        }
    }

    private func nextUnlockDate(for state: ProgressState, totalStories: Int) -> Date? {
        guard totalStories > 0 else {
            return nil
        }
        guard let lastCompletionDate = state.lastCompletionDate,
              let lastCompletedIndex = state.lastCompletedIndex else {
            return nil
        }
        guard state.unlockedCount <= lastCompletedIndex + 1 else {
            return nil
        }
        guard state.unlockedCount < totalStories else {
            return nil
        }
        return lastCompletionDate.addingTimeInterval(unlockInterval)
    }
}
