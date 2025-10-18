//
//  PrayerRecordsViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import Foundation
import SwiftUI

enum RecordsRange: String, CaseIterable, Identifiable {
    case week = "Weeks", month = "Months", year = "Years", all = "All time"
    var id: String { rawValue }
}

struct Summary {
    var jamaah: Int = 0
    var onTime: Int = 0
    var late: Int = 0
    var notPrayed: Int = 0
    var totalSlots: Int = 0

    var jamaahPct: Double { pct(jamaah) }
    var onTimePct: Double { pct(onTime) }
    var latePct: Double { pct(late) }
    var notPrayedPct: Double { pct(notPrayed) }

    private func pct(_ x: Int) -> Double { totalSlots == 0 ? 0 : Double(x)/Double(totalSlots) }
}

final class PrayerRecordsViewModel: ObservableObject {
    @Published var selectedRange: RecordsRange = .week
    @Published private(set) var days: [Date] = []                      // x-axis
    @Published private(set) var heatmap: [Date: [PrayerName: PrayerRecord]] = [:]
    @Published private(set) var summary = Summary()

    private let store: PrayerRecordsStore

    init(store: PrayerRecordsStore = CoreDataPrayerRecordsStore()) {
        self.store = store
        reload()
    }

    func reload() {
        let (from, to) = rangeDates(for: selectedRange)
        days = buildDays(from: from, to: to)
        heatmap = store.dailyMatrix(from: from, to: to)
        computeSummary(from: from, to: to)
    }

    func setRange(_ r: RecordsRange) {
        selectedRange = r
        reload()
    }

    private func computeSummary(from: Date, to: Date) {
        let recs = store.fetchRange(from: from, to: to)
        var s = Summary()
        s.totalSlots = days.count * PrayerName.allCases.count
        for r in recs {
            if r.inJamaah { s.jamaah += 1 }
            switch r.statusEnum {
            case .onTime:    s.onTime += 1
            case .late:      s.late += 1
            case .notPrayed: s.notPrayed += 1
            }
        }
        summary = s
    }

    private func rangeDates(for r: RecordsRange) -> (Date, Date) {
        let cal = Calendar.current
        let today = Date().startOfDay

        func monthStart(_ d: Date) -> Date {
            cal.date(from: cal.dateComponents([.year, .month], from: d))!
        }
        func monthEnd(_ d: Date) -> Date {
            let start = monthStart(d)
            let next  = cal.date(byAdding: .month, value: 1, to: start)!
            return cal.date(byAdding: .day, value: -1, to: next)!.startOfDay
        }

        switch r {
        case .week:
            // keep exact 7 days, doesn’t need month rounding
            let from = cal.date(byAdding: .day, value: -6, to: today)!
            return (from, today)

        case .month:
            // current month
            let from = monthStart(today)
            let to   = monthEnd(today)
            return (from, to)

        case .year:
            // last 12 full months (including current month)
            let fromMonth = cal.date(byAdding: .month, value: -11, to: monthStart(today))!
            return (fromMonth, monthEnd(today))

        case .all:
            // show last 24 full months (tweak if you prefer a different span)
            let fromMonth = cal.date(byAdding: .month, value: -23, to: monthStart(today))!
            return (fromMonth, monthEnd(today))
        }
    }


    private func buildDays(from: Date, to: Date) -> [Date] {
        var arr: [Date] = []
        var d = from
        while d <= to {
            arr.append(d)
            d = Calendar.current.date(byAdding: .day, value: 1, to: d)!
        }
        return arr
    }

    // Color for heatmap cell (match your theme)
    func color(for day: Date, prayer: PrayerName) -> Color {
        let key = day.startOfDay
        guard let r = heatmap[key]?[prayer] else {
            return AppColors.Prayers.heatmapEmpty
        }

        // --- Jumu'ah: Friday + Dhuhr ---
        if prayer == .dhuhr, day.isFriday {
            // Missed Jumu'ah = black; otherwise show Jumu'ah green
            return (r.statusEnum == .notPrayed)
                ? AppColors.Prayers.heatmapMissed
                : AppColors.Prayers.heatmapJamaah
        }

        // Non-Jumu'ah cells: ignore 'inJamaah' and map by status
        switch r.statusEnum {
        case .onTime:    return AppColors.Prayers.heatmapOnTime
        case .late:      return AppColors.Prayers.heatmapLate
        case .notPrayed: return AppColors.Prayers.heatmapMissed
        }
    }
    
    // PrayerRecordsViewModel.swift
    func record(for day: Date, prayer: PrayerName) -> PrayerRecord? {
        heatmap[day.startOfDay]?[prayer]
    }

}
