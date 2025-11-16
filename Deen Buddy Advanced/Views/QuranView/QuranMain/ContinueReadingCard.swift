//
//  ContinueReadingCard.swift
//  Deen Buddy Advanced
//
//  Card component for starting or continuing Quran reading
//

import SwiftUI

struct ContinueReadingCard: View {
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    let onTap: () -> Void

    private var lastPosition: (surahId: Int, verseId: Int)? {
        goalViewModel.getLastReadPosition()
    }

    private var isFirstTime: Bool {
        lastPosition == nil
    }

    private var buttonText: String {
        isFirstTime ? AppStrings.quran.startReading : AppStrings.quran.continueReading
    }

    private var displaySurahName: String? {
        guard let position = lastPosition,
              let surah = goalViewModel.getSurahs().first(where: { $0.id == position.surahId }) else {
            return nil
        }
        return surah.transliteration
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Image(systemName: isFirstTime ? "book.closed.fill" : "book.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.accentGreen)
                }

                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text(buttonText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    if isFirstTime {
                        Text(AppStrings.quran.beginYourJourney)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    } else if let surahName = displaySurahName,
                              let position = lastPosition {
                        HStack(spacing: 4) {
                            Text(AppStrings.quran.lastRead)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)

                            Text("\(surahName), \(AppStrings.reading.verse) \(position.verseId)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.VerseByVerse.accentGreen)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
           // .overlay(
             //   RoundedRectangle(cornerRadius: 20)
               //     .stroke(Color(.systemGray5), lineWidth: 1)
            //)
           // .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        ContinueReadingCard(
            goalViewModel: ReadingGoalViewModel.shared,
            onTap: {
                print("Continue reading tapped")
            }
        )
        .padding()
    }
    .background(Color(.systemBackground))
}
