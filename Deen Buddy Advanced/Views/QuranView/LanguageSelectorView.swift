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
                                    .foregroundColor(AppColors.Common.checkmarkSelected)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(AppStrings.quran.selectLanguage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quran.done) {
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
