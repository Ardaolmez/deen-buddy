//
//  GoalCardBackground.swift
//  Deen Buddy Advanced
//
//  Reusable background component for reading goal cards
//

import SwiftUI

struct GoalCardBackground: View {
    let imageOpacity: Double
    let imageBlur: Double
    let gradientOpacity: Double

    init(
        imageOpacity: Double = 0.8,
        imageBlur: Double = 1.1,
        gradientOpacity: Double = 0.1
    ) {
        self.imageOpacity = imageOpacity
        self.imageBlur = imageBlur
        self.gradientOpacity = gradientOpacity
    }

    var body: some View {
        ZStack {
            // Base background color
            AppColors.Today.cardBackground

            // Mosque painting background
            if let image = UIImage(named: "Quba mosque painting.jpg") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(imageOpacity)
                    .blur(radius: imageBlur)
            }

            // Subtle gradient overlay for text readability
            LinearGradient(
                colors: [
                    AppColors.Today.cardBackground.opacity(gradientOpacity),
                    AppColors.Today.cardBackground.opacity(gradientOpacity),
                    AppColors.Today.cardBackground.opacity(gradientOpacity)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
