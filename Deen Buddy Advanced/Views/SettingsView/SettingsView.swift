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
                languageSection
                aboutSection
            }
            .navigationTitle(AppStrings.settings.navigationTitle)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Language Section
    private var languageSection: some View {
        Section(header: Text(AppStrings.settings.quranTranslation)) {
            languagePicker

            Text(String(format: AppStrings.settings.selected, languageManager.selectedLanguage.displayName))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var languagePicker: some View {
        Picker(AppStrings.settings.language, selection: $languageManager.selectedLanguage) {
            ForEach(QuranLanguage.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section(header: Text(AppStrings.settings.about)) {
            HStack {
                Text(AppStrings.settings.appVersion)
                Spacer()
                Text(AppStrings.settings.version)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
