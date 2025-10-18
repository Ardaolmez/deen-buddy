//
//  PrayerLogStore.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

// Services/PrayerLogStore.swift
import Foundation

protocol PrayerLogStore {
    func loadDay(ymd: String) -> PrayerDayLog
    func saveDay(_ log: PrayerDayLog)
    func loadRange(ymdFrom: String, ymdTo: String) -> [PrayerDayLog]
}

final class DefaultsPrayerLogStore: PrayerLogStore {
    private let keyPrefix = "prayerlog."

    func loadDay(ymd: String) -> PrayerDayLog {
        let key = keyPrefix + ymd
        if let data = UserDefaults.standard.data(forKey: key),
           let log = try? JSONDecoder().decode(PrayerDayLog.self, from: data) {
            return log
        }
        return PrayerDayLog(ymd: ymd)
    }

    func saveDay(_ log: PrayerDayLog) {
        let key = keyPrefix + log.ymd
        if let data = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadRange(ymdFrom: String, ymdTo: String) -> [PrayerDayLog] {
        // naive impl for UD: iterate dates
        var out: [PrayerDayLog] = []
        var d = DateFormatter.yyyyMMdd.date(from: ymdFrom) ?? Date()
        let end = DateFormatter.yyyyMMdd.date(from: ymdTo) ?? Date()
        while d <= end {
            let y = DateFormatter.yyyyMMdd.string(from: d)
            out.append(loadDay(ymd: y))
            d = Calendar.current.date(byAdding: .day, value: 1, to: d)!
        }
        return out
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
