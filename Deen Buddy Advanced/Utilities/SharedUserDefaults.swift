//
//  SharedUserDefaults.swift
//  Shared UserDefaults using App Groups
//
//  Created for Deen Buddy Advanced
//

import Foundation

extension UserDefaults {
    /// Shared UserDefaults container for app and widget
    /// IMPORTANT: Configure App Groups in both targets with: group.com.vibalyzeou.deenbuddy
    static let shared = UserDefaults(suiteName: "group.com.vibalyzeou.deenbuddy")!

    // Keys
    private static let prayerDataKey = "prayerWidgetData"
    private static let lastCountryCodeKey = "lastCountryCode"
    private static let madhabKey = "selectedMadhab"

    // MARK: - Prayer Data

    func savePrayerData(_ data: PrayerWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            set(encoded, forKey: Self.prayerDataKey)
            synchronize() // Force write to disk
        }
    }

    func loadPrayerData() -> PrayerWidgetData? {
        guard let data = data(forKey: Self.prayerDataKey) else {
            return nil
        }
        return try? JSONDecoder().decode(PrayerWidgetData.self, from: data)
    }

    // MARK: - Location Context

    func saveCountryCode(_ code: String?) {
        set(code, forKey: Self.lastCountryCodeKey)
        synchronize()
    }

    func loadCountryCode() -> String? {
        return string(forKey: Self.lastCountryCodeKey)
    }

    // MARK: - Madhab Preference

    func saveMadhab(_ madhab: Madhab) {
        set(madhab.rawValue, forKey: Self.madhabKey)
        synchronize()
    }

    func loadMadhab() -> Madhab {
        guard let rawValue = string(forKey: Self.madhabKey),
              let madhab = Madhab(rawValue: rawValue) else {
            return .hanafi // Default to Hanafi
        }
        return madhab
    }
}
