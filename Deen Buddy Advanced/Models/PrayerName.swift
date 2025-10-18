//
//  PrayerName.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

// Models/PrayerEntry.swift
import Foundation
import Adhan

// Models/PrayerName.swift
import Foundation

enum PrayerName: String, CaseIterable, Identifiable, Codable {
    case fajr, dhuhr, asr, maghrib, isha
    // sunrise is used separately in the header; not part of this list
    var id: String { rawValue }
    var title: String {
        switch self {
        case .fajr: return "Fajr"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }
}

struct PrayerEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: PrayerName
    let time: Date
}
