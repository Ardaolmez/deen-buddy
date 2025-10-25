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
                    .init(color: AppColors.Quran.pageCenter, location: 0.0),
                    .init(color: AppColors.Quran.pageRing1, location: 0.25),
                    .init(color: AppColors.Quran.pageRing2, location: 0.5),
                    .init(color: AppColors.Quran.pageRing3, location: 0.75),
                    .init(color: AppColors.Quran.pageRing4, location: 1.0)
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
                    Color(red: 0.1, green: 0.1, blue: 0.25),  // Dark blue
                    Color(red: 0.15, green: 0.1, blue: 0.3),  // Purple-blue
                    Color(red: 0.08, green: 0.08, blue: 0.2)  // Deep blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Shining yellow stars
            Canvas { context, size in
                for _ in 0..<80 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let starSize = CGFloat.random(in: 1...3)
                    let brightness = Double.random(in: 0.6...1.0)

                    // Draw star
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: starSize, height: starSize)),
                        with: .color(Color.yellow.opacity(brightness))
                    )

                    // Add glow effect for some stars
                    if starSize > 2 {
                        context.opacity = 0.3
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: starSize + 4, height: starSize + 4)),
                            with: .color(.yellow)
                        )
                        context.opacity = 1.0
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
