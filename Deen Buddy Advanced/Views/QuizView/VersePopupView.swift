//
//  VersePopupView.swift
//  Deen Buddy Advanced
//
//  Pop-up view to display Quran verses in context
//
//  ⚠️ DEPRECATED: This file has been replaced by CenteredVerseModal.swift
//  The new modal provides a centered presentation with Arabic + English
//  in a more elegant design. This file is kept for reference only.
//  Please use CenteredVerseModal instead.
//

import SwiftUI

struct VersePopupView: View {
    @Environment(\.dismiss) private var dismiss
    let surahName: String
    let verseNumber: Int

    @State private var surah: Surah?

    var body: some View {
        NavigationStack {
            Group {
                if let surah = surah {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                // Surah Header
                                VStack(spacing: 8) {
                                    Text(surah.name)
                                        .font(.system(.title, design: .serif).weight(.bold))
                                        .foregroundColor(AppColors.Common.primary)
                                    Text(surah.transliteration)
                                        .font(.title3)
                                        .foregroundColor(AppColors.Common.secondary)
                                    Text(surah.translation!)
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.Common.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()

                                // Verses
                                ForEach(surah.verses) { verse in
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Verse number
                                        Text("\(AppStrings.quiz.verseLabel) \(verse.id)")
                                            .font(.caption)
                                            .foregroundColor(AppColors.Quiz.versePopupVerseNumber)

                                        // Arabic text
                                        Text(verse.text)
                                            .font(.system(.title3, design: .serif))
                                            .foregroundColor(AppColors.Quiz.verseArabicText)
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .fixedSize(horizontal: false, vertical: true)

                                        // Translation
                                        if let translation = verse.translation {
                                            Text(translation)
                                                .font(.body)
                                                .foregroundColor(AppColors.Quiz.verseTranslationText)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(verse.id == verseNumber ? AppColors.Quiz.versePopupHighlight : AppColors.Quiz.verseCardBackground)
                                    )
                                    .id(verse.id) // Important for scrolling
                                }
                                .padding(.horizontal)
                            }
                        }
                        .onAppear {
                            // Scroll immediately to target verse without animation
                            proxy.scrollTo(verseNumber, anchor: .center)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView(AppStrings.quiz.versePopupLoading)
                            .progressViewStyle(.circular)
                    }
                }
            }
            .navigationTitle(surahName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quiz.versePopupDone) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadSurah()
        }
    }

    private func loadSurah() {
        // Use current language setting instead of hardcoded English
        let surahs = QuranService.shared.loadQuran()
        surah = surahs.first { $0.transliteration == surahName }

        if surah == nil {
            print("⚠️ VersePopupView: Could not find surah '\(surahName)'")
        }
    }
}
