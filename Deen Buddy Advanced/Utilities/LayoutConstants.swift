//
//  LayoutConstants.swift
//  Deen Buddy Advanced
//
//  Responsive layout calculations for different iPhone screen sizes
//

import SwiftUI

struct LayoutConstants {

    // MARK: - Screen Size Detection

    static func isSmallDevice(height: CGFloat) -> Bool {
        return height < 700 // iPhone SE, iPhone 8, etc.
    }

    static func isMediumDevice(height: CGFloat) -> Bool {
        return height >= 700 && height < 850 // iPhone 14, 15, etc.
    }

    static func isLargeDevice(height: CGFloat) -> Bool {
        return height >= 850 // iPhone Pro Max models
    }

    // MARK: - Component Height Calculations
    // Heights are calculated as percentages of available screen height
    // Accounting for navigation bar (~100pt) and tab bar (~83pt)

    static func availableHeight(_ geometry: GeometryProxy) -> CGFloat {
        // Account for safe areas, navigation bar, and tab bar
        let safeAreaTop = geometry.safeAreaInsets.top
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        let navigationBarHeight: CGFloat = 96 // Large title navigation bar
        let tabBarHeight: CGFloat = 49

        return geometry.size.height - safeAreaTop - safeAreaBottom - navigationBarHeight - tabBarHeight
    }

    static func streakCardHeight(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)
        if isSmallDevice(height: geometry.size.height) {
            return available * 0.13 // 13% on small devices
        }
        return available * 0.12 // 12% on regular devices
    }

    static func verseCardHeight(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)
        if isSmallDevice(height: geometry.size.height) {
            return available * 0.16 // 16% on small devices
        }
        return available * 0.18 // 18% on regular devices
    }

    static func quizButtonHeight(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)
        return available * 0.08 // 8% on all devices
    }

    static func quranGoalCardHeight(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)
        if isSmallDevice(height: geometry.size.height) {
            return available * 0.24 // 24% on small devices
        }
        return available * 0.22 // 22% on regular devices
    }

    static func chatBoxHeight(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)
        return available * 0.08 // 8% on all devices
    }

    // MARK: - Spacing Calculations

    static func componentSpacing(for geometry: GeometryProxy) -> CGFloat {
        let available = availableHeight(geometry)

        // Calculate total component heights
        let totalComponentHeight = streakCardHeight(for: geometry) +
                                  verseCardHeight(for: geometry) +
                                  quizButtonHeight(for: geometry) +
                                  quranGoalCardHeight(for: geometry) +
                                  chatBoxHeight(for: geometry)

        // Remaining space for gaps between 5 components (4 gaps + top/bottom padding)
        let remainingSpace = available - totalComponentHeight

        // Distribute evenly between gaps (4 gaps between 5 components)
        let numberOfGaps: CGFloat = 4
        let spacing = max(8, remainingSpace / (numberOfGaps + 2)) // +2 for top/bottom padding

        return spacing
    }

    static func topPadding(for geometry: GeometryProxy) -> CGFloat {
        return componentSpacing(for: geometry)
    }

    static func bottomPadding(for geometry: GeometryProxy) -> CGFloat {
        return componentSpacing(for: geometry)
    }

    // MARK: - Font Size Calculations

    static func scaledFontSize(_ baseSize: CGFloat, for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let baseHeight: CGFloat = 852 // iPhone 14 Pro height as baseline
        let scaleFactor = screenHeight / baseHeight

        // Limit scaling to reasonable bounds
        let minScale: CGFloat = 0.85
        let maxScale: CGFloat = 1.15
        let clampedScale = min(max(scaleFactor, minScale), maxScale)

        return baseSize * clampedScale
    }

    // MARK: - Common Font Sizes

    static func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        return scaledFontSize(24, for: geometry)
    }

    static func headlineFontSize(for geometry: GeometryProxy) -> CGFloat {
        return scaledFontSize(17, for: geometry)
    }

    static func bodyFontSize(for geometry: GeometryProxy) -> CGFloat {
        return scaledFontSize(15, for: geometry)
    }

    static func captionFontSize(for geometry: GeometryProxy) -> CGFloat {
        return scaledFontSize(12, for: geometry)
    }

    // MARK: - Corner Radius Scaling

    static func cornerRadius(for geometry: GeometryProxy) -> CGFloat {
        if isSmallDevice(height: geometry.size.height) {
            return 12
        }
        return 16
    }

    // MARK: - Padding Calculations

    static func cardPadding(for geometry: GeometryProxy) -> CGFloat {
        if isSmallDevice(height: geometry.size.height) {
            return 16
        }
        return 20
    }

    static func horizontalPadding(for geometry: GeometryProxy) -> CGFloat {
        if isSmallDevice(height: geometry.size.height) {
            return 16
        }
        return 20
    }
}