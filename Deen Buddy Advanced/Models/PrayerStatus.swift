//
//  PrayerStatus.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import Foundation

enum PrayerStatus: Int16, CaseIterable, Codable, Identifiable {
    case notPrayed = 0
    case onTime    = 1
    case late      = 2
    var id: Int16 { rawValue }

    var title: String {
        switch self {
        case .notPrayed: "Not prayed"
        case .onTime:    "On time"
        case .late:      "Late"
        }
    }
}


