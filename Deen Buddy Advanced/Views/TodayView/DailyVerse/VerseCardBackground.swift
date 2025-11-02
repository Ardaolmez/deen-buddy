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

    init(
        imageOpacity: Double = 0.8,
        imageBlur: Double = 1.1,
        gradientOpacity: Double = 0.2
    ) {
        self.imageOpacity = imageOpacity
        self.imageBlur = imageBlur
        self.gradientOpacity = gradientOpacity
    }

    var body: some View {
        ZStack {
            // Base background color
            AppColors.Today.cardBackground

            // Tile image background
            if let image = UIImage(named: AppStrings.today.tileBackgroundImage) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(imageOpacity)
                    .blur(radius: imageBlur)
            }

            // Dark overlay for text readability and image darkening
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
