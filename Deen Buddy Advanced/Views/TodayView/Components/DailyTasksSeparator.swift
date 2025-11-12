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
                            AppColors.Today.separatorGradientColor
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            // Center icon
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Today.separatorIconColor)

                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.Today.separatorIconColor)

                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Today.separatorIconColor)
            }

            // Right line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.Today.separatorGradientColor,
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    DailyTasksSeparator()
        .padding()
        .background(AppColors.Today.papyrusBackground)
}
