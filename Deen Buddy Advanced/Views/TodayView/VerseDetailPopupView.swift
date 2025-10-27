//
//  VerseDetailPopupView.swift
//  Deen Buddy Advanced
//
//  Simple fullscreen view to display verse with citation card style
//

import SwiftUI

struct VerseDetailPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    let arabicText: String
    let translationText: String
    let reference: String
    let surahName: String

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppColors.Common.secondary)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Citation card
                    HStack(spacing: 8) {
                        Image(systemName: AppStrings.chat.citationIconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.Chat.citationCardIcon(for: colorScheme))

                        Text(reference)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.Chat.citationCardText(for: colorScheme))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppColors.Chat.citationCardBackground(for: colorScheme))
                    )
                    .padding(.horizontal, 20)

                    // Arabic text
                    if !arabicText.isEmpty {
                        Text(arabicText)
                            .font(.system(size: 28, weight: .medium, design: .serif))
                            .foregroundColor(AppColors.Common.primary)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }

                    // Translation text
                    if !translationText.isEmpty {
                        Text(translationText)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundColor(AppColors.Common.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    VerseDetailPopupView(
        arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        translationText: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        reference: "Al-Fatihah 1:1",
        surahName: "Al-Fatihah"
    )
}
