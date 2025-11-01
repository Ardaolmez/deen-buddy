//
//  SmallProgressRing.swift
//  Deen Buddy Advanced
//
//  Small circular progress indicator for daily goal card
//

import SwiftUI

struct SmallProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let text: String

    private var progressColor: Color {
        // Always use brand color (forest green)
        return AppColors.Today.quranGoalBrandColor
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 3)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Text inside
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.9), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        SmallProgressRing(progress: 0.0, text: "0/5")
            .frame(width: 44, height: 44)

        SmallProgressRing(progress: 0.3, text: "1/5")
            .frame(width: 44, height: 44)

        SmallProgressRing(progress: 0.6, text: "3/5")
            .frame(width: 44, height: 44)

        SmallProgressRing(progress: 1.0, text: "5/5")
            .frame(width: 44, height: 44)
    }
    .padding()
}
