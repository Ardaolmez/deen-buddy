//
//  VerseErrorState.swift
//  Deen Buddy Advanced
//
//  Error state view for daily verse card
//

import SwiftUI

struct VerseErrorState: View {
    let errorMessage: String

    var body: some View {
        Text(errorMessage)
            .font(.system(size: 15))
            .foregroundColor(AppColors.Today.verseCardSecondaryText)
            .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
            .padding(.vertical, 20)
    }
}
