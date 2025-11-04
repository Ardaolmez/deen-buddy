//
//  HijriDateBadge.swift
//  Deen Buddy Advanced
//
//  Created by Codex CLI on 2025-02-14.
//

import SwiftUI

struct HijriDateBadge: View {
    @ObservedObject var viewModel: HijriDateViewModel
    var onTap: (HijriDateViewModel) -> Void

    init(viewModel: HijriDateViewModel, onTap: @escaping (HijriDateViewModel) -> Void = { _ in }) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppColors.Explore.accentLight)
                    .frame(width: 30, height: 30)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.Explore.hijriCardAccent)
            }

            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.6)
                        .frame(width: 20, height: 20)
                } else {
                    Text(viewModel.hijriShortDateText)
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundColor(AppColors.Explore.hijriCardPrimaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .layoutPriority(1)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.Explore.subtleAccent,
                            AppColors.Explore.hijriCardBackground.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.Explore.cardShadow.opacity(0.45), radius: 8, x: 0, y: 3)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(AppColors.Explore.hijriCardBorder, lineWidth: 1)
        )
        .contentShape(Capsule(style: .continuous))
        .onTapGesture {
            onTap(viewModel)
        }
    }
}

#Preview {
    HijriDateBadge(viewModel: HijriDateViewModel())
        .padding()
        .background(Color.blue.opacity(0.2))
}
