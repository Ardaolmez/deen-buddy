//
//  ScreenDimensionManager.swift
//  Deen Buddy Advanced
//
//  Dynamic screen dimension calculation for adaptive reading experience
//

import SwiftUI
import UIKit

class ScreenDimensionManager: ObservableObject {
    static let shared = ScreenDimensionManager()
    
    @Published var currentDimensions: ScreenDimensions = ScreenDimensions()
    
    private init() {
        calculateDimensions()
        setupOrientationObserver()
    }
    
    // MARK: - Screen Dimensions Model
    
    struct ScreenDimensions {
        let screenWidth: CGFloat
        let screenHeight: CGFloat
        let safeAreaTop: CGFloat
        let safeAreaBottom: CGFloat
        let safeAreaLeading: CGFloat
        let safeAreaTrailing: CGFloat
        let deviceType: DeviceType
        let orientation: UIDeviceOrientation
        
        init() {
            let screen = UIScreen.main.bounds
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first { $0.isKeyWindow }
            
            self.screenWidth = screen.width
            self.screenHeight = screen.height
            self.safeAreaTop = window?.safeAreaInsets.top ?? 0
            self.safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
            self.safeAreaLeading = window?.safeAreaInsets.left ?? 0
            self.safeAreaTrailing = window?.safeAreaInsets.right ?? 0
            self.deviceType = DeviceType.current
            self.orientation = UIDevice.current.orientation
        }
        
        // Available reading area calculations
        var availableWidth: CGFloat {
            screenWidth - safeAreaLeading - safeAreaTrailing - (ReadingConstants.horizontalPadding * 2)
        }
        
        var availableHeight: CGFloat {
            screenHeight - safeAreaTop - safeAreaBottom - ReadingConstants.headerHeight - ReadingConstants.bottomPadding
        }
        
        // Optimal reading zone (60-70% of available height)
        var optimalReadingHeight: CGFloat {
            availableHeight * ReadingConstants.optimalReadingRatio
        }
        
        // Dynamic verse count calculation - increased for better page utilization
        var optimalVersesPerPage: Int {
            let estimatedVerseHeight = ReadingConstants.baseVerseHeight + ReadingConstants.verseSpacing
            let maxVerses = Int(availableHeight / estimatedVerseHeight)

            // Increased verses per page for better content density
            switch (deviceType, orientation.isLandscape) {
            case (.iPhone_SE, false): return max(8, min(maxVerses, 12))
            case (.iPhone_SE, true): return max(6, min(maxVerses, 10))
            case (.iPhone_Standard, false): return max(12, min(maxVerses, 16))
            case (.iPhone_Standard, true): return max(10, min(maxVerses, 14))
            case (.iPhone_Plus, false): return max(14, min(maxVerses, 18))
            case (.iPhone_Plus, true): return max(12, min(maxVerses, 16))
            case (.iPhone_Pro, false): return max(16, min(maxVerses, 20))
            case (.iPhone_Pro, true): return max(14, min(maxVerses, 18))
            case (.iPhone_ProMax, false): return max(18, min(maxVerses, 24))
            case (.iPhone_ProMax, true): return max(16, min(maxVerses, 22))
            case (.iPad, _): return max(24, min(maxVerses, 35))
            }
        }
        
        // Dynamic font size based on screen size
        var adaptiveFontSize: CGFloat {
            let baseFontSize: CGFloat = 16
            let scaleFactor = min(screenWidth / 375, screenHeight / 667) // iPhone 8 as baseline
            return baseFontSize * scaleFactor * ReadingConstants.fontScaleMultiplier
        }
        
        // Dynamic spacing calculations
        var adaptiveVerseSpacing: CGFloat {
            ReadingConstants.verseSpacing * (screenHeight / 667)
        }
        
        var adaptiveHorizontalPadding: CGFloat {
            ReadingConstants.horizontalPadding * (screenWidth / 375)
        }
    }
    
    // MARK: - Device Type Detection
    
    enum DeviceType {
        case iPhone_SE      // 4.7" and smaller
        case iPhone_Standard // 6.1" standard
        case iPhone_Plus    // 6.7" plus models
        case iPhone_Pro     // 6.1" pro models
        case iPhone_ProMax  // 6.7" pro max models
        case iPad
        
        static var current: DeviceType {
            let screen = UIScreen.main.bounds
            let screenHeight = max(screen.width, screen.height)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                return .iPad
            }
            
            switch screenHeight {
            case 0...667: return .iPhone_SE
            case 668...844: return .iPhone_Standard
            case 845...925: return .iPhone_Plus
            case 926...955: return .iPhone_Pro
            case 956...: return .iPhone_ProMax
            default: return .iPhone_Standard
            }
        }
    }
    
    // MARK: - Reading Constants

    struct ReadingConstants {
        static let horizontalPadding: CGFloat = 20
        static let headerHeight: CGFloat = 50  // Reduced from 80
        static let bottomPadding: CGFloat = 20  // Reduced from 40
        static let optimalReadingRatio: CGFloat = 0.85  // Increased from 0.65
        static let baseVerseHeight: CGFloat = 40  // Reduced from 60
        static let verseSpacing: CGFloat = 8  // Reduced from 16
        static let fontScaleMultiplier: CGFloat = 1.0

        // Animation constants
        static let pageTransitionDuration: Double = 0.3
        static let progressAnimationDuration: Double = 0.5
        static let achievementAnimationDuration: Double = 1.0
    }
    
    // MARK: - Public Methods
    
    func calculateDimensions() {
        DispatchQueue.main.async {
            self.currentDimensions = ScreenDimensions()
        }
    }
    
    func getOptimalPageConfiguration() -> PageConfiguration {
        let dimensions = currentDimensions
        return PageConfiguration(
            versesPerPage: dimensions.optimalVersesPerPage,
            fontSize: dimensions.adaptiveFontSize,
            verseSpacing: dimensions.adaptiveVerseSpacing,
            horizontalPadding: dimensions.adaptiveHorizontalPadding,
            availableWidth: dimensions.availableWidth,
            availableHeight: dimensions.availableHeight
        )
    }
    
    // MARK: - Page Configuration Model
    
    struct PageConfiguration {
        let versesPerPage: Int
        let fontSize: CGFloat
        let verseSpacing: CGFloat
        let horizontalPadding: CGFloat
        let availableWidth: CGFloat
        let availableHeight: CGFloat
        
        var isCompactLayout: Bool {
            versesPerPage <= 6
        }
        
        var shouldUseCondensedSpacing: Bool {
            versesPerPage >= 10
        }
    }
    
    // MARK: - Orientation Observer
    
    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Delay to ensure UI has updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.calculateDimensions()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIDeviceOrientation Extension

extension UIDeviceOrientation {
    var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }
}
