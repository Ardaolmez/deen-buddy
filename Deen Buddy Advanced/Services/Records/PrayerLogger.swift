//
//  PrayerLogger.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import Foundation

// Services/PrayerLogger.swift
import Foundation

final class PrayerLogger {
    private let store: PrayerLogStore
    init(store: PrayerLogStore = DefaultsPrayerLogStore()) { self.store = store }

    var todayYMD: String { DateFormatter.yyyyMMdd.string(from: Date()) }

    func setCompleted(_ prayer: PrayerName, _ completed: Bool, on date: Date = Date()) {
        var log = store.loadDay(ymd: DateFormatter.yyyyMMdd.string(from: date))
        if completed {
            log.completed.insert(prayer)
            log.completionTimes[prayer] = Date()
        } else {
            log.completed.remove(prayer)
            log.completionTimes.removeValue(forKey: prayer)
        }
        store.saveDay(log)
    }

    func isCompleted(_ prayer: PrayerName, on date: Date = Date()) -> Bool {
        let log = store.loadDay(ymd: DateFormatter.yyyyMMdd.string(from: date))
        return log.completed.contains(prayer)
    }

    func dayLog(date: Date = Date()) -> PrayerDayLog {
        store.loadDay(ymd: DateFormatter.yyyyMMdd.string(from: date))
    }

    // MARK: Stats

    /// Consecutive days where ALL prayers were completed
    func fullDayStreak(endingOn date: Date = Date()) -> Int {
        var streak = 0
        var d = date
        while true {
            let log = store.loadDay(ymd: DateFormatter.yyyyMMdd.string(from: d))
            if log.completed.count == PrayerName.allCases.count { streak += 1 }
            else { break }
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return streak
    }

    /// Per-prayer streak (e.g., Fajr only)
    func prayerStreak(_ prayer: PrayerName, endingOn date: Date = Date()) -> Int {
        var streak = 0
        var d = date
        while true {
            let log = store.loadDay(ymd: DateFormatter.yyyyMMdd.string(from: d))
            if log.completed.contains(prayer) { streak += 1 }
            else { break }
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return streak
    }

    /// Past 7 days completion percentage (0...1)
    func last7DaysCompletion() -> Double {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -6, to: end)!
        let from = DateFormatter.yyyyMMdd.string(from: start)
        let to = DateFormatter.yyyyMMdd.string(from: end)
        let logs = store.loadRange(ymdFrom: from, ymdTo: to)
        let total = logs.count * PrayerName.allCases.count
        let done = logs.reduce(0) { $0 + $1.completed.count }
        return total == 0 ? 0 : Double(done) / Double(total)
    }
}

