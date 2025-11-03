//
//  QuranView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct QuranView: View {
    @StateObject private var viewModel = QuranViewModel()
    @StateObject private var audioPlayer = QuranAudioPlayer()
    @EnvironmentObject var appState: AppState
    @State private var isAudioDrivenNavigation = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(AppStrings.quran.loading)
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(AppColors.Quran.toolbarText.opacity(0.7))
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.Quran.errorIcon)

                        Text(errorMessage)
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(AppColors.Quran.toolbarText.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Button(AppStrings.quran.retry) {
                            viewModel.loadQuran()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.currentSurah != nil {
                    // Main Quran Page with Audio
                    VStack(spacing: 0) {
                        TabView(selection: $viewModel.currentSurahIndex) {
                            ForEach(Array(viewModel.surahs.enumerated()), id: \.element.id) { index, surah in
                                QuranPageView(surah: surah, language: viewModel.selectedLanguage, audioPlayer: audioPlayer)
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
                        .onChange(of: viewModel.currentSurahIndex) { newIndex in
                            // Only reload audio if user manually changed surah
                            if !isAudioDrivenNavigation {
                                loadAudioForCurrentSurah(newIndex)
                            } else {
                                isAudioDrivenNavigation = false
                            }
                        }

                        // Audio Player Bar
                        QuranAudioBar(audioPlayer: audioPlayer)
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left: Settings
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.showSettings = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.Quran.toolbarText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
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
                                Text(String(format: AppStrings.quran.surahCount, surah.id))
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
            .sheet(isPresented: $viewModel.showSettings) {
                QuranSettingsView()
            }
            .sheet(isPresented: $viewModel.showSurahSelector) {
                SurahSelectorView(viewModel: viewModel)
            }
            .onAppear {
                loadAudioForCurrentSurah(viewModel.currentSurahIndex)
            }
            .onChange(of: appState.navigateToQuranWithAudio) { shouldNavigate in
                if shouldNavigate {
                    handleNavigationFromMainPage()
                }
            }
            .onChange(of: audioPlayer.currentSurahID) { newSurahID in
                // Sync UI when audio player moves to a different surah
                if let newSurahID = newSurahID {
                    isAudioDrivenNavigation = true
                    viewModel.goToSurahById(id: newSurahID)
                }
            }
        }
    }

    // MARK: - Navigation Handler
    private func handleNavigationFromMainPage() {
        guard let targetSurahID = appState.targetSurahID else { return }

        // Navigate to the target surah
        viewModel.goToSurahById(id: targetSurahID)

        // Load audio for the target surah and verse
        Task {
            await audioPlayer.loadSurah(targetSurahID, startingAtVerse: appState.targetVerseIndex)
            // Auto-play after loading
            audioPlayer.play()
            // Reset the navigation flag
            appState.resetNavigationFlag()
        }
    }

    // MARK: - Audio Integration
    private func loadAudioForCurrentSurah(_ index: Int) {
        guard index < viewModel.surahs.count else { return }

        let surah = viewModel.surahs[index]

        Task {
            await audioPlayer.loadSurah(surah.id, startingAtVerse: 0)
        }
    }
}

#Preview {
    QuranView()
}
