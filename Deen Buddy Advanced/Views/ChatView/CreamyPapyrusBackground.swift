//
//  CreamyPapyrusBackground.swift
//  Deen Buddy Advanced
//
//  Background for chat: Creamy papyrus for light mode, starry night for dark mode
//

import SwiftUI

struct CreamyPapyrusBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .light {
            // Light mode: Quran tab page background colors (radial gradient)
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.Quran.pageCenterBlue, location: 0.0),
                    .init(color: AppColors.Quran.pageRing1Blue, location: 0.25),
                    .init(color: AppColors.Quran.pageRing2Blue, location: 0.5),
                    .init(color: AppColors.Quran.pageRing3Blue, location: 0.75),
                    .init(color: AppColors.Quran.pageRing4Blue, location: 1.0)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        } else {
            // Dark mode: Night sky with stars
            StarryNightBackground()
        }
    }
}

struct StarryNightBackground: View {
    var body: some View {
        ZStack {
            // Dark blue-purple gradient background
            LinearGradient(
                colors: [
                    AppColors.Chat.darkBackgroundTop,
                    AppColors.Chat.darkBackgroundMid,
                    AppColors.Chat.darkBackgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Shining yellow stars (using cached star positions)
            Canvas { context, size in
                for star in StarFieldCache.shared.stars {
                    let x = star.x * size.width
                    let y = star.y * size.height
                    let starSize = star.size
                    let brightness = star.brightness

                    // Draw star
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                        with: .color(AppColors.Chat.starColor.opacity(brightness))
                    )

                    // Add glow effect for some stars
                    if starSize > 2 {
                        context.opacity = 0.3
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: starSize + 4, height: starSize + 4)),
                            with: .color(AppColors.Chat.starGlow)
                        )
                        context.opacity = 1.0
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
