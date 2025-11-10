//
//  VerseCardBackground.swift
//  Deen Buddy Advanced
//
//  Reusable background component for daily verse card
//

import SwiftUI

struct VerseCardBackground: View {
    let imageOpacity: Double
    let imageBlur: Double
    let gradientOpacity: Double
    let darkOverlayOpacity: Double

    // Get random image for daily verse (stable per day)
    private let randomImage: String

    init(
        imageOpacity: Double = 0.8,
        imageBlur: Double = 1.1,
        gradientOpacity: Double = 0.2,
        darkOverlayOpacity: Double = 0.4
    ) {
        self.imageOpacity = imageOpacity
        self.imageBlur = imageBlur
        self.gradientOpacity = gradientOpacity
        self.darkOverlayOpacity = darkOverlayOpacity

        // Get random background image (same image per day for consistency)
        self.randomImage = BackgroundImageManager.shared.getRandomImage(for: .dailyVerse)
    }

    var body: some View {
        ZStack {
            // Base background color
            AppColors.Today.cardBackground

            // Random mosque/Islamic art background
            if let image = UIImage(named: randomImage) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(imageOpacity)
                    .blur(radius: imageBlur)
            }

            // Dark overlay to make text more prominent
            Color.black.opacity(darkOverlayOpacity)

            // Additional gradient for depth and text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(gradientOpacity),
                    Color.black.opacity(gradientOpacity),
                    Color.black.opacity(gradientOpacity)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
