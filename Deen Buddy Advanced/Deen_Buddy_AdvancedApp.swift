//
//  Deen_Buddy_AdvancedApp.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

@main
struct Deen_Buddy_AdvancedApp: App {
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
