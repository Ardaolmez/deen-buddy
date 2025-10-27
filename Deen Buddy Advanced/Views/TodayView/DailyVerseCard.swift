//
//  DailyVerseCard.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct DailyVerseCard: View {
    @StateObject private var viewModel = DailyVerseViewModel()
    @State private var showFullVerse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.today.dailyVerseTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Today.verseCardPrimaryText)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Today.verseCardProgressTint))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)
                    .padding(.vertical, 20)
            } else {
                // Show truncated verse in selected language
                if let translation = viewModel.translationText, !translation.isEmpty {
                    Text(translation)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.Today.verseCardPrimaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .truncationMode(.tail)
                } else if !viewModel.arabicText.isEmpty {
                    // Fallback to Arabic if no translation available
                    Text(viewModel.arabicText)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(AppColors.Today.verseCardPrimaryText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                // Reference and tap hint
                HStack {
                    Text(viewModel.reference)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.Today.verseCardSecondaryText)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Tap to read full")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.8))
                        Image(systemName: "arrow.up.right.circle")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.8))
                    }
                }
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
        .contentShape(Rectangle())
        .onTapGesture {
            if !viewModel.isLoading && viewModel.errorMessage == nil {
                showFullVerse = true
            }
        }
        .fullScreenCover(isPresented: $showFullVerse) {
            VerseDetailPopupView(
                arabicText: viewModel.arabicText,
                translationText: viewModel.translationText ?? "",
                reference: viewModel.reference,
                surahName: viewModel.surahName
            )
        }
    }
}

#Preview {
    DailyVerseCard()
        .padding()
}
