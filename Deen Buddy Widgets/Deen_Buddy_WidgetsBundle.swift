//
//  Deen_Buddy_WidgetsBundle.swift
//  Deen Buddy Widgets
//
//  Created by Arda Olmez on 2025-10-18.
//

import WidgetKit
import SwiftUI

@main
struct Deen_Buddy_WidgetsBundle: WidgetBundle {
    var body: some Widget {
        PrayerTimeWidget()  // Prayer time widget with home & lock screen support

        // Template widgets (can be removed if not needed):
        // Deen_Buddy_Widgets()
        // Deen_Buddy_WidgetsControl()
        // Deen_Buddy_WidgetsLiveActivity()
    }
}
