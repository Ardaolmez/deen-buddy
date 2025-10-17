//
//  QuranView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct QuranView: View {
    @StateObject private var viewModel = QuranViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Quran...")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(AppColors.Quran.toolbarText.opacity(0.7))
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text(errorMessage)
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(AppColors.Quran.toolbarText.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            viewModel.loadQuran()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.currentSurah != nil {
                    // Main Quran Page
                    TabView(selection: $viewModel.currentSurahIndex) {
                        ForEach(Array(viewModel.surahs.enumerated()), id: \.element.id) { index, surah in
                            QuranPageView(surah: surah, language: viewModel.selectedLanguage)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.Quran.backgroundGradientStart,
                                AppColors.Quran.backgroundGradientEnd
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left: Language Selector
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.showLanguageSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(viewModel.selectedLanguage.rawValue.uppercased())
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.Quran.toolbarText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.Quran.toolbarBackground)
                        )
                    }
                }

                // Center: Surah Info
                ToolbarItem(placement: .principal) {
                    if let surah = viewModel.currentSurah {
                        Text(surah.transliteration)
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundColor(AppColors.Quran.toolbarText)
                    }
                }

                // Right: Surah Selector
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showSurahSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                            if let surah = viewModel.currentSurah {
                                Text("\(surah.id)/114")
                            }
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.Quran.toolbarText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.Quran.toolbarBackground)
                        )
                    }
                }
            }
            .sheet(isPresented: $viewModel.showLanguageSelector) {
                LanguageSelectorView()
            }
            .sheet(isPresented: $viewModel.showSurahSelector) {
                SurahSelectorView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    QuranView()
}
