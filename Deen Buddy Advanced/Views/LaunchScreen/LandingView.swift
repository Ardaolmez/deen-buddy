//
//  LandingView.swift
//  Deen Buddy Advanced
//
//  Initial landing page shown while assets preload
//

import SwiftUI

struct LandingView: View {
    let onReady: () -> Void

    @State private var isAnimating = false
    @State private var assetsLoaded = false
    @State private var minimumTimeElapsed = false

    // Minimum display time (seconds)
    private let minimumDuration: Double = 3.0

    var body: some View {
        ZStack {
            // Gradient background (no image needed - instant load)
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.35),
                    Color(red: 0.2, green: 0.3, blue: 0.4),
                    Color(red: 0.15, green: 0.2, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // App Icon/Logo
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.9))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                // App Name
                Text("Iman Buddy")
                    .font(.system(size: 36, weight: .medium, design: .serif))
                    .foregroundColor(.white)

                Spacer()

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("Loading...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            isAnimating = true
            preloadAllAssets()
            startMinimumTimer()
        }
        .onChange(of: assetsLoaded) { _ in
            checkAndProceed()
        }
        .onChange(of: minimumTimeElapsed) { _ in
            checkAndProceed()
        }
    }

    // MARK: - Preloading

    private func preloadAllAssets() {
        // Run on main thread for thread-safe dictionary access
        // Asset catalog loading is fast, won't block UI during 3-second landing
        DispatchQueue.main.async {
            BackgroundImageManager.shared.preloadLaunchImages()
            BackgroundImageManager.shared.preloadDailyCardImages()
            assetsLoaded = true
        }
    }

    private func startMinimumTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumDuration) {
            minimumTimeElapsed = true
        }
    }

    private func checkAndProceed() {
        if assetsLoaded && minimumTimeElapsed {
            withAnimation(.easeOut(duration: 0.3)) {
                onReady()
            }
        }
    }
}

#Preview {
    LandingView {
        print("Ready!")
    }
}
