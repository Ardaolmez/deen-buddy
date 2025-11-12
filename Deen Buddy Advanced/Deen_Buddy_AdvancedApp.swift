//
//  Deen_Buddy_AdvancedApp.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

// AppDelegate to handle orientation locking
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Lock to portrait orientation only
        return .portrait
    }
}

@main
struct Deen_Buddy_AdvancedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Initialize notification manager on app launch
        _ = PrayerNotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)  // Force light mode
                .onAppear {
                                   #if DEBUG
//                                   DemoData.seed(daysBack: 120) // seeds only if empty
                                   #endif
                               }
        }
    }
}
