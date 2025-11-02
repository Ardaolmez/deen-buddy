//
//  VerseLoadingState.swift
//  Deen Buddy Advanced
//
//  Loading state view for daily verse card
//

import SwiftUI

struct VerseLoadingState: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Today.verseCardProgressTint))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
    }
}
