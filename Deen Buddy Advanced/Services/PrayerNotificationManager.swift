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

    /// Schedule notifications for all prayer times
    /// - Parameters:
    ///   - dayTimes: The prayer times for the day
    ///   - cityLine: The location string (e.g., "New York, US")
    func schedulePrayerNotifications(for dayTimes: DayTimes, cityLine: String) {
        // First, check if we have permission
        checkPermissionStatus { [weak self] status in
            guard status == .authorized else {
                print("⚠️ Notifications not authorized. Current status: \(status.rawValue)")
                return
            }

            // Cancel existing notifications before scheduling new ones
            self?.cancelAllPrayerNotifications()

            // Schedule for each prayer
            self?.scheduleNotification(for: .fajr, time: dayTimes.fajr, cityLine: cityLine)
            self?.scheduleNotification(for: .dhuhr, time: dayTimes.dhuhr, cityLine: cityLine)
            self?.scheduleNotification(for: .asr, time: dayTimes.asr, cityLine: cityLine)
            self?.scheduleNotification(for: .maghrib, time: dayTimes.maghrib, cityLine: cityLine)
            self?.scheduleNotification(for: .isha, time: dayTimes.isha, cityLine: cityLine)

            print("✅ Scheduled notifications for all 5 prayers in \(cityLine)")
        }
    }

    /// Schedule a notification for a specific prayer
    private func scheduleNotification(for prayer: PrayerName, time: Date, cityLine: String) {
        // Don't schedule notifications for times that have already passed
        guard time > Date() else {
            print("⏭️ Skipping \(prayer.title) notification - time has passed")
            return
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

        // Create request with unique identifier
        let identifier = "prayer_\(prayer.rawValue)_\(dateIdentifier(for: time))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule the notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling \(prayer.title) notification: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                print("✅ Scheduled \(prayer.title) notification for \(formatter.string(from: time))")
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
