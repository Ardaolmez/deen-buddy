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
                            Color(red: 0.85, green: 0.8, blue: 0.7).opacity(0.5)
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
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))

                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))

                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))
            }

            // Right line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.8, blue: 0.7).opacity(0.5),
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
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
