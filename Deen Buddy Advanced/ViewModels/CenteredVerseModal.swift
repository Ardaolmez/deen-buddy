//
//  CenteredVerseModal.swift
//  Deen Buddy Advanced
//
//  Centered modal box displaying a single verse (Arabic + English)
//  Replaces bottom sheet VersePopupView with elegant centered design
//

import SwiftUI

struct CenteredVerseModal: View {
    @Environment(\.colorScheme) private var colorScheme

    let surahName: String
    let verseNumber: Int
    let onDismiss: () -> Void

    @State private var verse: Verse?
    @State private var surahInfo: (arabic: String, english: String, transliteration: String)?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Dark overlay background - dismisses on tap
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Centered modal card
            if isLoading {
                loadingView
            } else if let verse = verse, let surah = surahInfo {
                modalContent(verse: verse, surah: surah)
            } else {
                errorView
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .onAppear {
            loadVerse()
        }
    }

    // MARK: - Modal Content

    private func modalContent(verse: Verse, surah: (arabic: String, english: String, transliteration: String)) -> some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.textSecondary)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)

            ScrollView {
                VStack(spacing: 20) {
                    // Surah Header with decorative elements
                    surahHeader(surah: surah)
                        .padding(.top, 8)

                    // English translation card
                    if let translation = verse.translation {
                        translationTextView(text: translation)
                    }

                    // Verse number badge
                    verseNumberBadge(number: verseNumber)

                    // Arabic text card
                    arabicTextView(text: verse.text)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: 380, maxHeight: 600)
        .background(modalBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 32)
    }

    // MARK: - Surah Header

    private func surahHeader(surah: (arabic: String, english: String, transliteration: String)) -> some View {
        VStack(spacing: 12) {
            // Decorative top line
            HStack(spacing: 8) {
                decorativeLine()
                Circle()
                    .fill(AppColors.VerseByVerse.ornamentTop)
                    .frame(width: 6, height: 6)
                decorativeLine()
            }
            .padding(.horizontal, 30)

            // English name
            Text(surah.english)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(AppColors.VerseByVerse.surahName)

            // Transliteration
            Text(surah.transliteration)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.VerseByVerse.surahTransliteration)
                .tracking(1)
                .textCase(.uppercase)

            // Decorative bottom line
            HStack(spacing: 8) {
                decorativeLine()
                Circle()
                    .fill(AppColors.VerseByVerse.ornamentBottom)
                    .frame(width: 6, height: 6)
                decorativeLine()
            }
            .padding(.horizontal, 30)
        }
    }

    private func decorativeLine() -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        AppColors.VerseByVerse.dividerLine,
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }

    // MARK: - Arabic Text

    private func arabicTextView(text: String) -> some View {
        Text(text)
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(AppColors.VerseByVerse.arabicText)
            .multilineTextAlignment(.center)
            .lineSpacing(14)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.VerseByVerse.arabicCardGradient)
                    .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 8, x: 0, y: 2)
            )
    }

    // MARK: - Verse Number Badge

    private func verseNumberBadge(number: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.VerseByVerse.verseNumberBackground)
                .frame(width: 54, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.VerseByVerse.verseNumberBorder, lineWidth: 2)
                )
                .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 6, x: 0, y: 3)

            Text("\(number)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.VerseByVerse.verseNumberText)
        }
    }

    // MARK: - Translation Text

    private func translationTextView(text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundColor(AppColors.VerseByVerse.translationText)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.VerseByVerse.translationCardGradient)
                    .shadow(color: AppColors.VerseByVerse.shadowSecondary, radius: 8, x: 0, y: 4)
            )
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(AppColors.Prayers.prayerGreen)

            Text("Loading verse...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.VerseByVerse.textSecondary)
        }
        .frame(width: 200, height: 150)
        .background(modalBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Could not load verse")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.VerseByVerse.textPrimary)

            Button("Close") {
                onDismiss()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(AppColors.Prayers.prayerGreen)
            .cornerRadius(12)
        }
        .frame(width: 240, height: 200)
        .background(modalBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 32)
    }

    // MARK: - Background

    private var modalBackground: some View {
        ZStack {
            // Blur effect
            if colorScheme == .dark {
                Color(.systemGray6)
                    .opacity(0.95)
            } else {
                Color(.systemBackground)
                    .opacity(0.98)
            }

            // Subtle texture overlay
            Color.white.opacity(0.02)
        }
    }

    // MARK: - Data Loading

    private func loadVerse() {
        // Load Quran data using current language setting
        let surahs = QuranService.shared.loadQuran()

        // Find the target surah
        guard let surah = surahs.first(where: { $0.transliteration == surahName }) else {
            print("⚠️ CenteredVerseModal: Could not find surah '\(surahName)'")
            isLoading = false
            return
        }

        // Find the target verse
        guard let targetVerse = surah.verses.first(where: { $0.id == verseNumber }) else {
            print("⚠️ CenteredVerseModal: Could not find verse \(verseNumber) in \(surahName)")
            isLoading = false
            return
        }

        // Use the surah's translation field (respects current language)
        let translatedName = surah.translation ?? surah.transliteration

        // Set the data
        verse = targetVerse
        surahInfo = (
            arabic: surah.name,
            english: translatedName,
            transliteration: surah.transliteration
        )
        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        CenteredVerseModal(surahName: "Al-Fatihah", verseNumber: 1, onDismiss: {})
    }
}
