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

    // MARK: - Prayer Data

    func savePrayerData(_ data: PrayerWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            set(encoded, forKey: Self.prayerDataKey)
            synchronize() // Force write to disk
            print("💾 [Shared] Saved prayer data for widget")
        }
    }

    func loadPrayerData() -> PrayerWidgetData? {
        guard let data = data(forKey: Self.prayerDataKey) else {
            print("⚠️ [Shared] No prayer data found")
            return nil
        }
        let decoded = try? JSONDecoder().decode(PrayerWidgetData.self, from: data)
        if decoded != nil {
            print("✅ [Shared] Loaded prayer data successfully")
        }
        return decoded
    }
}
