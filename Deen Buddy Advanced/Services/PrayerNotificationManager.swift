//
//  PrayerNotificationManager.swift
//  Deen Buddy Advanced
//
//  Created by Claude on 2025-11-11.
//

import Foundation
import UserNotifications
import Combine

/// Manages local notifications for prayer times
final class PrayerNotificationManager: NSObject {
    static let shared = PrayerNotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private var bag = Set<AnyCancellable>()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - Permission Management

    /// Request notification permissions from the user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
                    completion(granted)
                }
            }
        }
    }

    /// Check current notification permission status
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Schedule Prayer Notifications

    /// Schedule notifications for all prayer times for multiple days
    /// - Parameters:
    ///   - prayerTimesList: Array of prayer times for multiple days
    ///   - cityLine: The location string (e.g., "New York, US")
    func schedulePrayerNotifications(for prayerTimesList: [(date: Date, times: DayTimes)], cityLine: String) {
        // First, check if we have permission
        checkPermissionStatus { [weak self] status in
            guard status == .authorized else {
                print("⚠️ Notifications not authorized. Current status: \(status.rawValue)")
                return
            }

            // Only validate cityLine when scheduling, not when it's still loading
            guard !cityLine.isEmpty && cityLine != "Locating..." else {
                print("⚠️ Cannot schedule notifications: location not ready (cityLine: '\(cityLine)')")
                return
            }

            // Cancel existing notifications before scheduling new ones
            self?.cancelAllPrayerNotifications()

            var totalScheduled = 0
            // Schedule for each day
            for dayPrayers in prayerTimesList {
                self?.scheduleNotification(for: .fajr, time: dayPrayers.times.fajr, cityLine: cityLine, date: dayPrayers.date)
                self?.scheduleNotification(for: .dhuhr, time: dayPrayers.times.dhuhr, cityLine: cityLine, date: dayPrayers.date)
                self?.scheduleNotification(for: .asr, time: dayPrayers.times.asr, cityLine: cityLine, date: dayPrayers.date)
                self?.scheduleNotification(for: .maghrib, time: dayPrayers.times.maghrib, cityLine: cityLine, date: dayPrayers.date)
                self?.scheduleNotification(for: .isha, time: dayPrayers.times.isha, cityLine: cityLine, date: dayPrayers.date)
                totalScheduled += 5
            }

            print("✅ Scheduled \(totalScheduled) notifications for \(prayerTimesList.count) days in \(cityLine)")
        }
    }

    /// Schedule notifications for a single day (backward compatibility)
    /// - Parameters:
    ///   - dayTimes: The prayer times for the day
    ///   - cityLine: The location string (e.g., "New York, US")
    func schedulePrayerNotifications(for dayTimes: DayTimes, cityLine: String) {
        let today = Date()
        schedulePrayerNotifications(for: [(date: today, times: dayTimes)], cityLine: cityLine)
    }

    /// Schedule a notification for a specific prayer
    private func scheduleNotification(for prayer: PrayerName, time: Date, cityLine: String, date: Date) {
        // Don't schedule notifications for times that have already passed
        guard time > Date() else {
            return  // Silently skip - this is normal for past prayers
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "🕌 Time for \(prayer.title) Prayer"
        content.body = "It's time to pray \(prayer.title) in \(cityLine)"
        content.sound = .default
        content.categoryIdentifier = "PRAYER_REMINDER"
        content.userInfo = [
            "prayerName": prayer.rawValue,
            "prayerTime": ISO8601DateFormatter().string(from: time),
            "location": cityLine
        ]

        // Create trigger based on the prayer time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create request with unique identifier using the date parameter
        let identifier = "prayer_\(prayer.rawValue)_\(dateIdentifier(for: date))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling \(prayer.title) notification: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                print("✅ Scheduled \(prayer.title) for \(formatter.string(from: time))")
            }
        }
    }

    // MARK: - Cancel Notifications

    /// Cancel all prayer notifications
    func cancelAllPrayerNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerIdentifiers = requests
                .filter { $0.identifier.starts(with: "prayer_") }
                .map { $0.identifier }

            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: prayerIdentifiers)
            print("🗑️ Cancelled \(prayerIdentifiers.count) prayer notifications")
        }
    }

    /// Cancel notifications for a specific prayer
    func cancelNotification(for prayer: PrayerName, date: Date) {
        let identifier = "prayer_\(prayer.rawValue)_\(dateIdentifier(for: date))"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled \(prayer.title) notification")
    }

    // MARK: - Helper Methods

    /// Generate a unique date identifier (YYYYMMDD format)
    private func dateIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }

    /// List all pending prayer notifications (for debugging)
    func listPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let prayerNotifications = requests.filter { $0.identifier.starts(with: "prayer_") }
            DispatchQueue.main.async {
                completion(prayerNotifications)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PrayerNotificationManager: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let prayerName = userInfo["prayerName"] as? String {
            print("📱 User tapped notification for \(prayerName) prayer")
            // You can add navigation logic here if needed
            // e.g., open the Prayers tab when user taps the notification
        }

        completionHandler()
    }
}
