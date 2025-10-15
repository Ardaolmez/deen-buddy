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
                Section(header: Text("Quran Translation")) {
                    Picker("Language", selection: $languageManager.selectedLanguage) {
                        ForEach(QuranLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }

                    Text("Selected: \(languageManager.selectedLanguage.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Future sections can be added here
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
