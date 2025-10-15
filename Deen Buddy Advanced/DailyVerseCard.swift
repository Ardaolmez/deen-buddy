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
            Text("Daily Quran Verse for You")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            } else {
                // Show verse in selected language
                if let translation = viewModel.translationText, !translation.isEmpty {
                    Text(translation)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                } else if !viewModel.arabicText.isEmpty {
                    // Fallback to Arabic if no translation available
                    Text(viewModel.arabicText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // Reference
                Text(viewModel.reference)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DailyVerseCard()
}
