//
//  SurahListCard.swift
//  Deen Buddy Advanced
//
//  Card component displaying all Surahs with verse selection
//

import SwiftUI

struct SurahListCard: View {
    let surahs: [Surah]
    let onNavigate: (Int, Int) -> Void  // (surahId, verseId)

    @State private var showVerseNavigation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.quran.surahs)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Text(AppStrings.quran.browseAllSurahs)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Count badge
                Text("114")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppColors.VerseByVerse.accentGreen)
                    )
            }
            .padding(20)

            Divider()

            // Surah list preview (first 5)
            VStack(spacing: 0) {
                ForEach(Array(surahs.prefix(5).enumerated()), id: \.element.id) { index, surah in
                    SurahRowCompact(surah: surah)

                    if index < 4 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }

            Divider()

            // View All button
            Button(action: {
                showVerseNavigation = true
            }) {
                HStack {
                    Text(AppStrings.quran.tapToSelect)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.accentGreen)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.accentGreen)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showVerseNavigation) {
            VerseNavigationPopup(surahs: surahs, onNavigate: onNavigate)
        }
    }
}

// Compact row for surah preview - just numbers
struct SurahRowCompact: View {
    let surah: Surah

    var body: some View {
        HStack(spacing: 12) {
            // Surah number
            ZStack {
                Circle()
                    .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                    .frame(width: 40, height: 40)

                Text("\(surah.id)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.VerseByVerse.accentGreen)
            }

            Spacer()

            // Verse count
            Text("\(surah.verses.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

#Preview {
    SurahListCard(
        surahs: QuranService.shared.loadQuran(language: .english),
        onNavigate: { surahId, verseId in
            print("Navigate to Surah \(surahId), Verse \(verseId)")
        }
    )
    .padding()
    .background(Color(.systemBackground))
}
