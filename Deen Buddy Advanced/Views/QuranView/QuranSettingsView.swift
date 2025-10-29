//
//  QuranSettingsView.swift
//  Deen Buddy Advanced
//
//  Settings popover for Quran reading preferences
//

import SwiftUI

struct QuranSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var fontSizeManager = QuranFontSizeManager.shared
    @State private var sampleArabicText = AppStrings.quran.sampleBismillah
    @State private var sampleEnglishText = AppStrings.quran.sampleBismillahTranslation

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Language Selection Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Translation Language", systemImage: "globe")
                            .font(.headline)
                            .foregroundColor(AppColors.Quran.toolbarText)

                        ForEach(QuranLanguage.allCases, id: \.self) { language in
                            Button(action: {
                                languageManager.selectedLanguage = language
                            }) {
                                HStack {
                                    Text(language.displayName)
                                        .foregroundColor(AppColors.Quran.toolbarText)

                                    Spacer()

                                    if languageManager.selectedLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.Quran.selectorBadgeStart)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(languageManager.selectedLanguage == language ?
                                              AppColors.Quran.toolbarBackground :
                                              Color.clear)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(AppColors.Quran.pageRing2)
                    .cornerRadius(12)

                    // Font Size Section
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Font Size", systemImage: "textformat.size")
                            .font(.headline)
                            .foregroundColor(AppColors.Quran.toolbarText)

                        // Font size preset buttons
                        HStack(spacing: 8) {
                            ForEach(QuranFontSizeManager.FontSize.allCases, id: \.self) { fontSize in
                                Button(action: {
                                    fontSizeManager.currentFontSize = fontSize
                                }) {
                                    Text(String(fontSize.displayName.prefix(1)))
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(fontSizeManager.currentFontSize == fontSize ?
                                                      AppColors.Quran.selectorBadgeStart :
                                                      AppColors.Quran.toolbarBackground)
                                        )
                                        .foregroundColor(
                                            fontSizeManager.currentFontSize == fontSize ?
                                            .white : AppColors.Quran.toolbarText
                                        )
                                }
                            }
                        }

                        // Fine adjustment controls
                        HStack(spacing: 16) {
                            Button(action: {
                                fontSizeManager.decreaseFontSize()
                            }) {
                                Image(systemName: "textformat.size.smaller")
                                    .font(.system(size: 20))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppColors.Quran.toolbarBackground)
                                    )
                                    .foregroundColor(AppColors.Quran.toolbarText)
                            }
                            .disabled(fontSizeManager.fontSizeMultiplier <= fontSizeManager.minMultiplier)

                            Spacer()

                            Text("\(Int(fontSizeManager.fontSizeMultiplier * 100))%")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.Quran.toolbarText)

                            Spacer()

                            Button(action: {
                                fontSizeManager.increaseFontSize()
                            }) {
                                Image(systemName: "textformat.size.larger")
                                    .font(.system(size: 20))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppColors.Quran.toolbarBackground)
                                    )
                                    .foregroundColor(AppColors.Quran.toolbarText)
                            }
                            .disabled(fontSizeManager.fontSizeMultiplier >= fontSizeManager.maxMultiplier)
                        }

                        // Reset button
                        Button(action: {
                            fontSizeManager.resetToDefault()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Default")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(AppColors.Quran.surahMetadata)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(AppColors.Quran.pageRing2)
                    .cornerRadius(12)

                    // Preview Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Preview", systemImage: "eye")
                            .font(.headline)
                            .foregroundColor(AppColors.Quran.toolbarText)

                        VStack(alignment: .trailing, spacing: 12) {
                            // Arabic text preview
                            Text(sampleArabicText)
                                .font(.system(size: fontSizeManager.scaledFontSize(28), design: .serif))
                                .foregroundColor(AppColors.Quran.toolbarText)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            // Translation preview (if not Arabic)
                            if languageManager.selectedLanguage != .arabic {
                                Text(sampleEnglishText)
                                    .font(.system(size: fontSizeManager.scaledFontSize(18)))
                                    .foregroundColor(AppColors.Quran.surahMetadata)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(AppColors.Quran.toolbarBackground)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(AppColors.Quran.pageRing2)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(AppColors.Quran.backgroundGradientStart)
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.Quran.selectorBadgeStart)
                }
            }
        }
    }
}

#Preview {
    QuranSettingsView()
}