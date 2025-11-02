//
//  DailyVerseCard.swift
//  Deen Buddy Advanced
//
//  Compact card for daily Quran verse
//

import SwiftUI

struct DailyVerseCard: View {
    @StateObject private var viewModel = DailyVerseViewModel()
    @State private var showFullVerse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(AppStrings.today.dailyVerseTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.Today.verseCardPrimaryText)
                .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)

            // State-based content
            if viewModel.isLoading {
                VerseLoadingState()
            } else if let errorMessage = viewModel.errorMessage {
                VerseErrorState(errorMessage: errorMessage)
            } else {
                VerseCardContent(
                    translationText: viewModel.translationText,
                    arabicText: viewModel.arabicText,
                    reference: viewModel.reference
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(VerseCardBackground(imageOpacity: 0.8, imageBlur: 1.1, gradientOpacity: 0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Today.quranGoalBrandColor.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: AppColors.Today.verseCardShadow.opacity(0.04), radius: 2, x: 0, y: 1)
        .shadow(color: AppColors.Today.verseCardShadow.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: AppColors.Today.quranGoalBrandColor.opacity(0.05), radius: 16, x: 0, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            if !viewModel.isLoading && viewModel.errorMessage == nil {
                showFullVerse = true
            }
        }
        .sheet(isPresented: $showFullVerse) {
            if let verse = viewModel.verse {
                VersePopupView(
                    surahName: viewModel.surahName,
                    verseNumber: verse.id
                )
            }
        }
    }
}

#Preview {
    DailyVerseCard()
        .padding()
}
