//
//  DailyTasksSeparator.swift
//  Deen Buddy Advanced
//
//  Beautiful separator for daily tasks section
//

import SwiftUI

struct DailyTasksSeparator: View {
    var body: some View {
        HStack(spacing: 16) {
            // Left line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            AppColors.Today.brandGreen
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: 80, maxHeight: 3)

            // Center text
            Text(TodayStrings.selfLearningTitle)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .italic()
                .foregroundColor(AppColors.Today.brandGreen)

            // Right line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.Today.brandGreen,
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: 80, maxHeight: 3)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DailyTasksSeparator()
        .padding()
        .background(AppColors.Today.papyrusBackground)
}
