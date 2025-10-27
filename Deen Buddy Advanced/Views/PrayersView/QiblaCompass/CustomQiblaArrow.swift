//
//  CustomQiblaArrow.swift
//  Deen Buddy Advanced
//
//  Custom arrow design for Qibla compass
//

import SwiftUI

struct CustomQiblaArrow: View {
    let isAligned: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            // Shadow/glow effect
            arrowShape
                .fill(
                    LinearGradient(
                        colors: isAligned ?
                            [AppColors.Prayers.prayerGreen.opacity(0.3), AppColors.Prayers.prayerGreen.opacity(0.1)] :
                            [AppColors.Prayers.prayerBlue.opacity(0.3), AppColors.Prayers.prayerBlue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 8)
                .scaleEffect(1.1)

            // Main arrow with gradient
            arrowShape
                .fill(
                    LinearGradient(
                        colors: isAligned ?
                            [AppColors.Prayers.prayerGreen, AppColors.Prayers.prayerGreen.opacity(0.8)] :
                            [AppColors.Prayers.prayerBlue, AppColors.Prayers.prayerBlue.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Highlight on top
            arrowShape
                .stroke(
                    isAligned ?
                        AppColors.Prayers.prayerGreen.opacity(0.5) :
                        AppColors.Prayers.prayerBlue.opacity(0.5),
                    lineWidth: 2
                )
        }
        .frame(width: size, height: size * 1.2)
    }

    private var arrowShape: some Shape {
        ArrowShape()
    }
}

// Custom arrow shape
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Arrow head (top triangle)
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.35))

        // Arrow body (shaft)
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.85))
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.85))
        path.addLine(to: CGPoint(x: width * 0.75, y: height))
        path.addLine(to: CGPoint(x: width * 0.25, y: height))
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.85))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.85))

        // Back to arrow head
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.35))
        path.closeSubpath()

        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        CustomQiblaArrow(isAligned: false, size: 70)
        CustomQiblaArrow(isAligned: true, size: 70)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
