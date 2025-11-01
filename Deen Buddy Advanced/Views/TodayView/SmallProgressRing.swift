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
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.67 {
            return .green
        } else if progress >= 0.34 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Text inside
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
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
