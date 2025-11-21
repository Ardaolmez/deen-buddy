//
//  AppLanguagePickerView.swift
//  Deen Buddy Advanced
//
//  Minimal language picker for testing localization
//

import SwiftUI

struct AppLanguagePickerView: View {
    @ObservedObject var appLanguageManager = AppLanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        appLanguageManager.currentLanguage = language
                    }) {
                        HStack {
                            Text(language.flag)
                                .font(.title2)
                            Text(language.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if appLanguageManager.currentLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("App Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AppLanguagePickerView()
}
