//
//  DailyVerseCard.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyVerseCard: View {
    @StateObject private var viewModel = DailyVerseViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.today.dailyVerseTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.Today.verseCardPrimaryText)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Today.verseCardProgressTint))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)
            } else {
                // Show verse in selected language
                if let translation = viewModel.translationText, !translation.isEmpty {
                    Text(translation)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.Today.verseCardPrimaryText)
                        .multilineTextAlignment(.leading)
                } else if !viewModel.arabicText.isEmpty {
                    // Fallback to Arabic if no translation available
                    Text(viewModel.arabicText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.Today.verseCardPrimaryText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // Reference
                Text(viewModel.reference)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.Today.verseCardGradientStart, AppColors.Today.verseCardGradientEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: AppColors.Today.verseCardShadow, radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DailyVerseCard()
}
