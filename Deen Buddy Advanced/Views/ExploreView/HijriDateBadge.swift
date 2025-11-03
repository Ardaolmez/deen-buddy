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
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(AppStrings.appName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.Explore.hijriCardPrimaryText)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.65)
                        .frame(height: 14)
                } else {
                    Text(viewModel.hijriShortDateText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            Image(systemName: "calendar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.Explore.hijriCardAccent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(AppColors.Explore.hijriCardBackground.opacity(0.9))
                .shadow(color: AppColors.Explore.cardShadow.opacity(0.5), radius: 8, x: 0, y: 3)
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
