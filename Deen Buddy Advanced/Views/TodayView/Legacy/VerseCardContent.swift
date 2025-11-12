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
        VStack(alignment: .center, spacing: 1) {
            // Translation or Arabic text - EMPHASIZED
            if let translation = translationText, !translation.isEmpty {
                Text(translation)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else if !arabicText.isEmpty {
                Text(arabicText)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 5, x: 0, y: 3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(.vertical, 12)
            }

            // Reference - small and centered
            VStack( spacing: 8) {
                Text(reference)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText)
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.5), radius: 2, x: 0, y: 1)

                    //HStack(spacing: 4) {
                   // Text(AppStrings.today.tapToReadFull)
                       // .font(.system(size: 10))
                     //   .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.5))
                   // Image(systemName: "arrow.up.right.circle")
                   //     .font(.system(size: 10))
                 //       .foregroundColor(AppColors.Today.verseCardSecondaryText.opacity(0.5))
               // }
                //.shadow(color: AppColors.Today.verseCardShadow.opacity(0.4), radius: 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
