//
//  LanguageSelectorView.swift
//  Deen Buddy Advanced
//
//  Language selection sheet for Quran
//

import SwiftUI

struct LanguageSelectorView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(QuranLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        languageManager.selectedLanguage = language
                        dismiss()
                    }) {
                        HStack {
                            Text(language.displayName)
                                .font(.system(size: 17))
                                .foregroundColor(.primary)

                            Spacer()

                            if languageManager.selectedLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LanguageSelectorView()
}
