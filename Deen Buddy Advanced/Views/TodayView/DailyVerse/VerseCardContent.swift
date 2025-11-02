//
//  VerseCardContent.swift
//  Deen Buddy Advanced
//
//  Main verse content display (translation/arabic + reference)
//

import SwiftUI

struct VerseCardContent: View {
    let translationText: String?
    let arabicText: String
    let reference: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Translation or Arabic text
            if let translation = translationText, !translation.isEmpty {
                Text(translation)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .truncationMode(.tail)
            } else if !arabicText.isEmpty {
                Text(arabicText)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 5, x: 0, y: 3)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            // Reference and tap hint
            HStack {
                Text(reference)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.6), radius: 3, x: 0, y: 2)

                Spacer()

                HStack(spacing: 4) {
                    Text(AppStrings.today.tapToReadFull)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.8))
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.8))
                }
                .shadow(color: AppColors.Today.verseCardShadow.opacity(0.5), radius: 3, x: 0, y: 2)
            }
        }
    }
}
