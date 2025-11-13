//
//  VerseNavigationPopup.swift
//  Deen Buddy Advanced
//
//  Two-step verse navigation popup
//

import SwiftUI

struct VerseNavigationPopup: View {
    @Environment(\.dismiss) private var dismiss
    let surahs: [Surah]
    let onNavigate: (Int, Int) -> Void  // (surahId, verseId)

    @State private var step: NavigationStep = .surahSelection
    @State private var selectedSurah: Surah?

    enum NavigationStep {
        case surahSelection
        case verseSelection
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if step == .surahSelection {
                        surahSelectionView
                    } else {
                        verseSelectionView
                    }
                }
            }
            .navigationTitle(step == .surahSelection ? "Select Surah" : "Select Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if step == .verseSelection {
                        Button("Back") {
                            withAnimation {
                                step = .surahSelection
                                selectedSurah = nil
                            }
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if step == .surahSelection {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Surah Selection (One per row)

    private var surahSelectionView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(surahs, id: \.id) { surah in
                    Button(action: {
                        selectedSurah = surah
                        withAnimation {
                            step = .verseSelection
                        }
                    }) {
                        HStack(spacing: 16) {
                            // Surah number circle
                            ZStack {
                                Circle()
                                    .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                                    .frame(width: 44, height: 44)

                                Text("\(surah.id)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.VerseByVerse.accentGreen)
                            }

                            // Surah name
                            VStack(alignment: .leading, spacing: 4) {
                                Text(surah.translation ?? surah.transliteration)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text(surah.transliteration)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Verse count
                            Text("\(surah.verses.count) verses")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)

                            // Chevron
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider()
                        .padding(.leading, 80)
                }
            }
        }
    }

    // MARK: - Step 2: Verse Selection (5 per row grid)

    private var verseSelectionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let surah = selectedSurah {
                    // Surah info header
                    VStack(spacing: 8) {
                        Text(surah.translation ?? surah.transliteration)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)

                        Text(surah.transliteration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("\(surah.verses.count) verses")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Verse number grid (5 per row)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(1...surah.verses.count, id: \.self) { verseNumber in
                            Button(action: {
                                onNavigate(surah.id, verseNumber)
                                dismiss()
                            }) {
                                Text("\(verseNumber)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.VerseByVerse.accentGreen)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    VerseNavigationPopup(
        surahs: QuranService.shared.loadQuran(language: .english),
        onNavigate: { surahId, verseId in
            print("Navigate to Surah \(surahId), Verse \(verseId)")
        }
    )
}
