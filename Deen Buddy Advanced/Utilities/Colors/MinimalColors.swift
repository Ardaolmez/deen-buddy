//
//  MinimalColors.swift
//  Deen Buddy Advanced
//
//  Minimal color palette for clean design
//

import SwiftUI

extension Color {
    // MARK: - Minimal Prayer Colors
    static let prayerGreen = Color.green
    static let prayerBlue = Color.blue
    static let prayerOrange = Color.orange
    
    // Subtle backgrounds
    static let subtleGreen = Color.green.opacity(0.08)
    static let subtleBlue = Color.blue.opacity(0.08)
    static let subtleGray = Color(.systemGray6)
    
    // Shadow colors
    static let greenShadow = Color.green.opacity(0.2)
    static let blueShadow = Color.blue.opacity(0.2)
    static let lightShadow = Color.black.opacity(0.05)
}

// MARK: - Minimal Design System
struct MinimalDesign {
    // Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // Corner radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    
    // Icon sizes
    static let smallIcon: CGFloat = 16
    static let mediumIcon: CGFloat = 20
    static let largeIcon: CGFloat = 32
    static let extraLargeIcon: CGFloat = 48
    
    // Circle sizes
    static let smallCircle: CGFloat = 40
    static let mediumCircle: CGFloat = 56
    static let largeCircle: CGFloat = 80
}
