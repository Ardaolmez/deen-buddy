//
//  DailyProgressViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for managing daily progress tracking
//

import Foundation
import Combine

class DailyProgressViewModel: ObservableObject {
    @Published var progressTracker: DailyProgressTracker
    @Published var dailyVerse: DailyActivityContent?
    @Published var dailyDurood: DailyActivityContent?
    @Published var dailyDua: DailyActivityContent?
    @Published var selectedDate: Date = Date()

    private let userDefaultsKey = "dailyProgressTracker"

    init() {
        // Load saved progress tracker
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(DailyProgressTracker.self, from: data) {
            self.progressTracker = decoded
        } else {
            self.progressTracker = DailyProgressTracker()
        }

        // Load daily content
        loadDailyContent()
    }

    // MARK: - Load Daily Content

    private func loadDailyContent() {
        dailyVerse = getDailyVerse()
        dailyDurood = getDailyDurood()
        dailyDua = getDailyDua()
    }

    // MARK: - JSON Loading Helper

    private func loadJSON<T: Decodable>(filename: String) -> [T]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to locate \(filename).json in bundle")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load \(filename).json")
            return nil
        }

        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode([T].self, from: data) else {
            print("Failed to decode \(filename).json")
            return nil
        }

        return decoded
    }

    // MARK: - Content Providers

    private func getDailyVerse() -> DailyActivityContent {
        // Load verses from JSON
        guard let verses: [DailyActivityContent] = loadJSON(filename: "dailyverses"),
              !verses.isEmpty else {
            // Fallback if JSON fails to load
            return DailyActivityContent(
                type: .verse,
                title: "Remember Allah",
                arabicText: "فَاذْكُرُونِي أَذْكُرْكُمْ",
                transliteration: "Fadhkurooneee adhkurkum",
                translation: "Remember Me; I will remember you.",
                reference: "Surah Al-Baqarah 2:152",
                tags: ["REMEMBRANCE"]
            )
        }

        // Select verse based on day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % verses.count
        return verses[index]
    }

    private func getDailyDurood() -> DailyActivityContent {
        // Load durood from JSON
        guard let duroods: [DailyActivityContent] = loadJSON(filename: "dailydurood"),
              !duroods.isEmpty else {
            // Fallback if JSON fails to load
            return DailyActivityContent(
                type: .durood,
                title: "Simple Durood",
                arabicText: "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
                transliteration: "Allahumma salli wa sallim 'ala nabiyyina Muhammad",
                translation: "O Allah, send prayers and peace upon our Prophet Muhammad.",
                reference: "Common Salawat",
                tags: ["BLESSINGS", "PROPHET"]
            )
        }

        // Select durood based on day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % duroods.count
        return duroods[index]
    }

    private func getDailyDua() -> DailyActivityContent {
        // Load duas from JSON
        guard let duas: [DailyActivityContent] = loadJSON(filename: "dailyduas"),
              !duas.isEmpty else {
            // Fallback if JSON fails to load
            return DailyActivityContent(
                type: .dua,
                title: "Seeking Forgiveness",
                arabicText: "أَسْتَغْفِرُ اللَّهَ",
                transliteration: "Astaghfirullah",
                translation: "I seek forgiveness from Allah.",
                reference: "Common Dua",
                tags: ["FORGIVENESS"]
            )
        }

        // Select dua based on day of year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % duas.count
        return duas[index]
    }

    // MARK: - Mark Complete

    func markActivityComplete(_ type: DailyActivityType) {
        progressTracker.markActivityComplete(type, for: selectedDate)
        save()
    }

    func isActivityCompleted(_ type: DailyActivityType) -> Bool {
        return progressTracker.isActivityCompleted(type)
    }

    // MARK: - Progress Data

    var todayProgress: Int {
        return progressTracker.todayProgress
    }

    var currentStreak: Int {
        return progressTracker.currentStreak
    }

    var bestStreak: Int {
        return progressTracker.bestStreak
    }

    var last7Days: [Bool] {
        return progressTracker.getLast7Days()
    }

    // MARK: - Date Navigation

    func navigateToPreviousDay() {
        guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else { return }
        selectedDate = previousDay
    }

    func navigateToNextDay() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        guard selectedDate < Date() else { return }
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
              nextDay < tomorrow else { return }
        selectedDate = nextDay
    }

    func isSelectedDateToday() -> Bool {
        return Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }

    func isSelectedDateFuture() -> Bool {
        return selectedDate > Date()
    }

    func getProgressForSelectedDate() -> Int {
        let key = progressTracker.dateKey(from: selectedDate)
        if let record = progressTracker.completionHistory[key] {
            return record.progressPercentage
        }
        return 0
    }

    func isActivityCompletedForSelectedDate(_ type: DailyActivityType) -> Bool {
        let key = progressTracker.dateKey(from: selectedDate)
        if let record = progressTracker.completionHistory[key] {
            return record.completedActivities.contains(type)
        }
        return false
    }

    // MARK: - Persistence

    private func save() {
        if let encoded = try? JSONEncoder().encode(progressTracker) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
