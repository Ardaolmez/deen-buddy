//
//  LanguageSettingsView.swift
//  Deen Buddy Advanced
//
//  Language selection screen for app UI language
//

import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject var languageManager = AppLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        languageManager.currentLanguage = language
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)

                            Text(language.displayName)
                                .foregroundColor(AppColors.Common.primary)

                            Spacer()

                            if languageManager.currentLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.Common.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Section {
                Text(AppStrings.settings.moreLanguagesComingSoon)
                    .font(.caption)
                    .foregroundColor(AppColors.Common.secondary)
            }
        }
        .navigationTitle(AppStrings.settings.language)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        LanguageSettingsView()
    }
}
