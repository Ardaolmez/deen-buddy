//
//  WordOfWisdomCard.swift
//  Deen Buddy Advanced
//
//  Compact card for daily Word of Wisdom
//

import SwiftUI

struct WordOfWisdomCard: View {
    @StateObject private var viewModel = WordOfWisdomViewModel()
    @State private var showWordOfWisdom = false

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Title
            HStack(spacing: 6) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)

                Text("Word of Wisdom")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.Today.verseCardSecondaryText)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            .shadow(color: AppColors.Today.verseCardShadow.opacity(0.5), radius: 3, x: 0, y: 1)

            // State-based content
            if viewModel.isLoading {
                VerseLoadingState()
            } else if let errorMessage = viewModel.errorMessage {
                VerseErrorState(errorMessage: errorMessage)
            } else if let wisdom = viewModel.wordOfWisdom {
                WordOfWisdomCardContent(
                    quote: wisdom.quote,
                    author: wisdom.author
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(20)
        .background(VerseCardBackground(imageOpacity: 0.8, imageBlur: 1.1, gradientOpacity: 0.2))
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
                showWordOfWisdom = true
            }
        }
        .fullScreenCover(isPresented: $showWordOfWisdom) {
            if let wisdom = viewModel.wordOfWisdom {
                WordOfWisdomDetailView(wisdom: wisdom)
            }
        }
    }
}

// MARK: - Word of Wisdom Card Content
struct WordOfWisdomCardContent: View {
    let quote: String
    let author: String

    // Truncate quote if too long
    private var displayQuote: String {
        if quote.count > 120 {
            let index = quote.index(quote.startIndex, offsetBy: 120)
            return String(quote[..<index]) + "..."
        }
        return quote
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Opening quote mark
            Text("\u{201C}")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.Today.quranGoalBrandColor.opacity(0.6))
                .offset(y: 10)

            // Quote text
            Text(displayQuote)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.Today.verseCardPrimaryText)
                .shadow(color: AppColors.Today.verseCardShadow.opacity(0.7), radius: 4, x: 0, y: 2)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)

            // Closing quote mark
            Text("\u{201D}")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.Today.quranGoalBrandColor.opacity(0.6))
                .offset(y: -10)

            // Author with decorative line
            VStack(spacing: 4) {
                Rectangle()
                    .fill(AppColors.Today.quranGoalBrandColor.opacity(0.4))
                    .frame(width: 40, height: 2)
                    .cornerRadius(1)

                Text("- \(author)")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(AppColors.Today.verseCardPrimaryText.opacity(0.9))
                    .shadow(color: AppColors.Today.verseCardShadow.opacity(0.5), radius: 2, x: 0, y: 1)
                    .italic()
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    WordOfWisdomCard()
        .padding()
}
