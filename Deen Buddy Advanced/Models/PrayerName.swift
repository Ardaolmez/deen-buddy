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

// Models/PrayerEntry.swift
import Foundation

import Foundation

enum PrayerName: String, CaseIterable, Identifiable, Codable, Hashable {
    case fajr, dhuhr, asr, maghrib, isha   // sunrise excluded

    // Stable identity for ForEach, etc.
    var id: String { rawValue }

    // Long title for rows/cards
    var title: String {
        switch self {
        case .fajr:    return "Fajr"
        case .dhuhr:   return "Dhuhr"
        case .asr:     return "Asr"
        case .maghrib: return "Maghrib"
        case .isha:    return "Isha"
        }
    }

    // Short label (useful for compact UIs if needed)
    var short: String {
        switch self {
        case .fajr:    return "Fajr"
        case .dhuhr:   return "Dhuhr"
        case .asr:     return "Asr"
        case .maghrib: return "Magh"
        case .isha:    return "Isha"
        }
    }

    // SF Symbol used in the heatmap row labels / legend
    var icon: String {
        switch self {
        case .fajr:    return "moon.circle.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.and.horizon.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.stars.fill"
        }
    }

    // Optional: position index if you need sorting elsewhere
    var index: Int {
        switch self {
        case .fajr: return 0
        case .dhuhr: return 1
        case .asr: return 2
        case .maghrib: return 3
        case .isha: return 4
        }
    }

    // Convenience ordered list (same as allCases but explicit)
    static let ordered: [PrayerName] = [.fajr, .dhuhr, .asr, .maghrib, .isha]
}


struct PrayerEntry: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: PrayerName
    let time: Date
}

