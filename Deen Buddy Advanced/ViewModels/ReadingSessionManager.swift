//
//  ReadingSessionManager.swift
//  Deen Buddy Advanced
//
//  Manages reading session timer and app lifecycle
//

import Foundation
import SwiftUI
import Combine

class ReadingSessionManager: ObservableObject {
    static let shared = ReadingSessionManager()

    @Published var elapsedSeconds: Int = 0
    @Published var isActive: Bool = false

    private var timer: Timer?
    private var sessionStartTime: Date?
    private var sessionStartSeconds: Int = 0  // Track where this session started
    private let userDefaults = UserDefaults.standard

    // Keys for persistence
    private let todaySecondsKey = "todayReadingSeconds"
    private let lastDateKey = "lastReadingDate"

    // Reference to ReadingGoalViewModel for updating
    weak var goalViewModel: ReadingGoalViewModel?

    init() {
        loadTodaySeconds()
    }

    // MARK: - Timer Control

    func startSession() {
        guard !isActive else { return }

        isActive = true
        sessionStartTime = Date()
        sessionStartSeconds = elapsedSeconds  // Remember where we started this session

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func stopSession() {
        guard isActive else { return }

        isActive = false
        timer?.invalidate()
        timer = nil

        // Save accumulated time
        saveTodaySeconds()
    }

    func pauseSession() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }

    func resumeSession() {
        guard !isActive else { return }

        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    // MARK: - Persistence

    private func loadTodaySeconds() {
        let savedDate = userDefaults.object(forKey: lastDateKey) as? Date ?? Date.distantPast
        let today = Calendar.current.startOfDay(for: Date())
        let savedDay = Calendar.current.startOfDay(for: savedDate)

        if today == savedDay {
            // Same day, load saved seconds
            elapsedSeconds = userDefaults.integer(forKey: todaySecondsKey)
        } else {
            // New day, reset
            elapsedSeconds = 0
            userDefaults.set(0, forKey: todaySecondsKey)
            userDefaults.set(Date(), forKey: lastDateKey)
        }
    }

    private func saveTodaySeconds() {
        userDefaults.set(elapsedSeconds, forKey: todaySecondsKey)
        userDefaults.set(Date(), forKey: lastDateKey)
    }

    // MARK: - Session End

    func endSession(versesRead: Int, currentSurahId: Int, currentVerseId: Int) {
        stopSession()

        // Calculate only the NEW minutes from this session
        let sessionSeconds = elapsedSeconds - sessionStartSeconds
        let sessionMinutes = sessionSeconds / 60

        // Update ReadingGoalViewModel with only the new session time
        goalViewModel?.recordReadingActivity(verses: versesRead, minutes: sessionMinutes)

        // Save position
        goalViewModel?.saveLastReadPosition(surahId: currentSurahId, verseId: currentVerseId)
    }

    // MARK: - Helpers

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progressPercentage: Double {
        let goalSeconds = 5 * 60 // 5 minutes goal
        return min(Double(elapsedSeconds) / Double(goalSeconds), 1.0)
    }

    deinit {
        timer?.invalidate()
    }
}
