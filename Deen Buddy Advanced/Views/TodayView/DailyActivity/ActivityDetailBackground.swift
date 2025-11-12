//
//  ActivityDetailBackground.swift
//  Deen Buddy Advanced
//
//  Reusable background component for daily activity detail view
//

import SwiftUI

struct ActivityDetailBackground: View {
    let activityType: DailyActivityType

    // Random background image for this activity type
    private var backgroundImageName: String {
        switch activityType {
        case .verse:
            return BackgroundImageManager.shared.getRandomImage(for: .verse)
        case .durood:
            return BackgroundImageManager.shared.getRandomImage(for: .durood)
        case .dua:
            return BackgroundImageManager.shared.getRandomImage(for: .dua)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base background color
                AppColors.Today.cardBackground
                    .ignoresSafeArea()

                // Random background image
                if let image = UIImage(named: backgroundImageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width)
                        .ignoresSafeArea()
                } else {
                    // Fallback gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.Today.fallbackGradientStart,
                            AppColors.Today.fallbackGradientMid,
                            AppColors.Today.fallbackGradientEnd
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }

                // Dark overlay to make text more prominent
                AppColors.Today.darkOverlay
                    .ignoresSafeArea()

                // Additional gradient for depth
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.Today.gradientOverlayLight,
                        AppColors.Today.gradientOverlayMedium,
                        AppColors.Today.gradientOverlayDark
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }
}
