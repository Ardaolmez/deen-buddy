//
//  ProgressRing.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

// ProgressRing.swift
import SwiftUI

struct ProgressRing: View {
    var progress: Double   // 0.0 ... 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.Quiz.progressRingBackground, lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppColors.Quiz.progressRingFill, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(round(progress * 100)))%")
                .font(.system(.title3, design: .serif).weight(.semibold))
        }
    }
}
