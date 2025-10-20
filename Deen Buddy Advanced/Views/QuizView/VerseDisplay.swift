//
//  VerseDisplay.swift
//  Deen Buddy Advanced
//
//  Component to display Quranic verse with Arabic and translation
//

import SwiftUI

struct VerseDisplay: View {
    let verse: Verse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text(AppStrings.quiz.quranVerse)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.Quiz.explanationReference)

            // Arabic text (right-aligned)
            Text(verse.text)
                .font(.system(.title3, design: .serif))
                .foregroundColor(AppColors.Quiz.verseArabicText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 8)

            // English translation
            if let translation = verse.translation {
                Text(translation)
                    .font(.body)
                    .foregroundColor(AppColors.Quiz.verseTranslationText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.Quiz.verseCardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}
