//
//  SharedUserDefaults+Widget.swift
//  Deen Buddy Widgets
//
//  UserDefaults extension for App Groups
//

import Foundation

extension UserDefaults {
    /// Shared UserDefaults container for app and widget
    /// IMPORTANT: Configure App Groups in both targets with: group.com.vibalyzeou.deenbuddy
    static let shared = UserDefaults(suiteName: "group.com.vibalyzeou.deenbuddy")!

    // Keys
    private static let prayerDataKey = "prayer_widget_data"
    private static let lastCountryCodeKey = "lastCountryCode"

    // MARK: - Prayer Data

    func savePrayerData(_ data: PrayerWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            set(encoded, forKey: Self.prayerDataKey)
            synchronize()
        }
    }

    func loadPrayerData() -> PrayerWidgetData? {
        guard let data = data(forKey: Self.prayerDataKey) else { return nil }
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
}
