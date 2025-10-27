//
//  VerseDetailPopupView.swift
//  Deen Buddy Advanced
//
//  Beautiful popup view to display full verse with Arabic text and translation
//

import SwiftUI

struct VerseDetailPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    let arabicText: String
    let translationText: String
    let reference: String // e.g. "Al-Baqarah 2:255"
    let surahName: String

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    dismissWithAnimation()
                }

            // Content card
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Text(AppStrings.today.dailyVerseTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.Today.verseCardPrimaryText)

                        Spacer()

                        Button(action: {
                            dismissWithAnimation()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppColors.Common.secondary)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.Today.verseCardGradientStart.opacity(0.8),
                                AppColors.Today.verseCardGradientEnd.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Surah info
                            VStack(spacing: 8) {
                                Text(surahName)
                                    .font(.system(.title2, design: .serif).weight(.bold))
                                    .foregroundColor(AppColors.Common.primary)

                                Text(reference)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.Common.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                            Divider()
                                .padding(.horizontal)

                            // Arabic text
                            if !arabicText.isEmpty {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text(CommonStrings.arabic)
                                        .font(.caption)
                                        .foregroundColor(AppColors.Common.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(arabicText)
                                        .font(.system(size: LayoutConstants.scaledFontSize(26, for: geometry),
                                                    weight: .medium,
                                                    design: .serif))
                                        .foregroundColor(AppColors.Common.primary)
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal)
                            }

                            // Translation text
                            if !translationText.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(CommonStrings.translation)
                                        .font(.caption)
                                        .foregroundColor(AppColors.Common.secondary)

                                    Text(translationText)
                                        .font(.system(size: LayoutConstants.scaledFontSize(18, for: geometry),
                                                    weight: .regular,
                                                    design: .serif))
                                        .foregroundColor(AppColors.Common.primary)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal)
                            }

                            // Citation card style indicator
                            HStack {
                                Spacer()

                                HStack(spacing: 6) {
                                    Image(systemName: AppStrings.chat.citationIconName)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(AppColors.Chat.citationCardIcon(for: colorScheme))

                                    Text(reference)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColors.Chat.citationCardText(for: colorScheme))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(AppColors.Chat.citationCardBackground(for: colorScheme))
                                )

                                Spacer()
                            }
                            .padding(.vertical)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .frame(maxWidth: min(geometry.size.width * 0.9, 500))
                .frame(maxHeight: geometry.size.height * 0.8)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .scaleEffect(scale)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                opacity = 1
                scale = 1
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            opacity = 0
            scale = 0.9
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    VerseDetailPopupView(
        arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        translationText: "In the name of Allah, the Most Gracious, the Most Merciful",
        reference: "Al-Fatihah 1:1",
        surahName: "Al-Fatihah - The Opening"
    )
}
