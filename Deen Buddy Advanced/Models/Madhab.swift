//
//  Madhab.swift
//  Deen Buddy Advanced
//
//  Prayer school/madhab for Asr prayer calculation
//

import Foundation

enum Madhab: String, CaseIterable, Codable {
    case shafi = "shafi"
    case hanafi = "hanafi"

    var displayName: String {
        switch self {
        case .shafi:
            return AppStrings.prayers.madhabShafi
        case .hanafi:
            return AppStrings.prayers.madhabHanafi
        }
    }

    var description: String {
        switch self {
        case .shafi:
            return AppStrings.prayers.madhabShafiDesc
        case .hanafi:
            return AppStrings.prayers.madhabHanafiDesc
        }
    }
}
