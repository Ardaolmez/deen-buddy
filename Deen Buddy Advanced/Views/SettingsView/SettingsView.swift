//
//  SettingsView.swift
//  Deen Buddy Advanced
//
//  Settings screen for app preferences
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var appLanguageManager = AppLanguageManager.shared

    var body: some View {
        NavigationView {
            Form {
                appLanguageSection
                languageSection
                aboutSection
            }
            .navigationTitle(AppStrings.settings.navigationTitle)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - App Language Section
    private var appLanguageSection: some View {
        Section(header: Text(AppStrings.settings.appLanguage)) {
            NavigationLink(destination: LanguageSettingsView()) {
                HStack {
                    Text(AppStrings.settings.language)
                    Spacer()
                    Text("\(appLanguageManager.currentLanguage.flag) \(appLanguageManager.currentLanguage.displayName)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Quran Translation Section
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
