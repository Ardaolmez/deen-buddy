//
//  SettingsView.swift
//  Deen Buddy Advanced
//
//  Settings screen for app preferences
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var audioService = QuranAudioService.shared

    var body: some View {
        NavigationView {
            Form {
                languageSection
                audioSection
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

    // MARK: - Audio Section
    private var audioSection: some View {
        Section(header: Text("Audio Recitation")) {
            audioLanguagePicker
            arabicReciterPicker
            englishReciterPicker

            Text("Choose your preferred audio language and reciter for Quran playback")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var audioLanguagePicker: some View {
        Picker("Audio Language", selection: $audioService.selectedLanguage) {
            ForEach(AudioLanguage.allCases, id: \.self) { language in
                Text(language.displayName).tag(language)
            }
        }
    }

    @ViewBuilder
    private var arabicReciterPicker: some View {
        if audioService.selectedLanguage == .arabic || audioService.selectedLanguage == .both {
            Picker("Arabic Reciter", selection: $audioService.arabicReciter) {
                ForEach(AudioReciter.reciters.filter { $0.language == .arabic }, id: \.id) { reciter in
                    Text(reciter.name).tag(reciter)
                }
            }
        }
    }

    @ViewBuilder
    private var englishReciterPicker: some View {
        if audioService.selectedLanguage == .english || audioService.selectedLanguage == .both {
            Picker("English Narrator", selection: $audioService.englishReciter) {
                ForEach(AudioReciter.reciters.filter { $0.language == .english }, id: \.id) { reciter in
                    Text(reciter.name).tag(reciter)
                }
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
