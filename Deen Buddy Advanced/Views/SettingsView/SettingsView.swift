//
//  SettingsView.swift
//  Deen Buddy Advanced
//
//  Settings screen for app preferences
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var languageManager = LanguageManager.shared

    var body: some View {
        NavigationView {
            Form {
                // Language Section
                Section(header: Text(AppStrings.settings.quranTranslation)) {
                    Picker(AppStrings.settings.language, selection: $languageManager.selectedLanguage) {
                        ForEach(QuranLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }

                    Text(String(format: AppStrings.settings.selected, languageManager.selectedLanguage.displayName))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Future sections can be added here
                Section(header: Text(AppStrings.settings.about)) {
                    HStack {
                        Text(AppStrings.settings.appVersion)
                        Spacer()
                        Text(AppStrings.settings.version)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(AppStrings.settings.navigationTitle)
        }
    }
}

#Preview {
    SettingsView()
}
