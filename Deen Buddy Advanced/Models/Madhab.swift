//
//  Madhab.swift
//  Deen Buddy Advanced
//
//  Prayer school/madhab for Asr prayer calculation
//

import Foundation

enum Madhab: String, CaseIterable, Codable {
    case shafi = "Shafi'i"
    case hanafi = "Hanafi"

    var displayName: String {
        return self.rawValue
    }

    var description: String {
        switch self {
        case .shafi:
            return "Standard (Shafi'i, Maliki, Hanbali)"
        case .hanafi:
            return "Later Asr time (Hanafi)"
        }
    }
}
