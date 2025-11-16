//
//  JuzListCard.swift
//  Deen Buddy Advanced
//
//  Card component displaying all Juz with verse selection
//

import SwiftUI

struct JuzListCard: View {
    let surahs: [Surah]
    let onNavigate: (Int, Int) -> Void  // (surahId, verseId)

    @State private var showVerseNavigation = false

    private let allJuz = Juz.allJuz

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.quran.juz)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Text(AppStrings.quran.browseAllJuz)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Count badge
                Text("30")
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

            // Juz list preview (first 5)
            VStack(spacing: 0) {
                ForEach(Array(allJuz.prefix(5).enumerated()), id: \.element.id) { index, juz in
                    JuzRowCompact(juz: juz, surahs: surahs)

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
            // For now, using same VerseNavigationPopup - will navigate to Juz start
            VerseNavigationPopup(surahs: surahs, onNavigate: onNavigate)
        }
    }
}

// Compact row for juz preview - just numbers
struct JuzRowCompact: View {
    let juz: Juz
    let surahs: [Surah]

    var body: some View {
        HStack(spacing: 12) {
            // Juz number
            ZStack {
                Circle()
                    .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                    .frame(width: 40, height: 40)

                Text("\(juz.id)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.VerseByVerse.accentGreen)
            }

            Spacer()

            // Approximate verse count
            Text("~\(juz.approximateVerseCount)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

#Preview {
    JuzListCard(
        surahs: QuranService.shared.loadQuran(language: .english),
        onNavigate: { surahId, verseId in
            print("Navigate to Surah \(surahId), Verse \(verseId)")
        }
    )
    .padding()
    .background(Color(.systemBackground))
}
