//
//  PrayerLog.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

// Models/PrayerLog.swift
import Foundation

//enum PrayerName: String, CaseIterable, Identifiable, Codable {
//    case fajr, dhuhr, asr, maghrib, isha
//    var id: String { rawValue }
//    var title: String {
//        switch self {
//        case .fajr: "Fajr"; case .dhuhr: "Dhuhr"; case .asr: "Asr"
//        case .maghrib: "Maghrib"; case .isha: "Isha"
//        }
//    }
//}

struct PrayerDayLog: Codable, Equatable {
    /// yyyyMMdd
    var ymd: String
    /// Which prayers are completed on this day
    var completed: Set<PrayerName> = []
    /// Optional timestamp when a specific prayer was marked done
    var completionTimes: [PrayerName: Date] = [:]
}
