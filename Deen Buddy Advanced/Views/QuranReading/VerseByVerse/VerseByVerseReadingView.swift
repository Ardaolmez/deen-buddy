//
//  VerseByVerseReadingView.swift
//  Deen Buddy Advanced
//
//  Main view for verse-by-verse Quran reading with fancy dark mode design
//

import SwiftUI

struct VerseByVerseReadingView: View {
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    @Binding var isPresented: Bool
    @ObservedObject private var sessionManager = ReadingSessionManager.shared
    @Environment(\.scenePhase) private var scenePhase

    @State private var pages: [QuranReadingPage] = []
    @State private var currentPageIndex: Int = 0
    @State private var startingPosition: Int = 0
    @State private var showVerseNavigation: Bool = false

    var currentSurahAndVerse: String {
        guard !pages.isEmpty,
              currentPageIndex < pages.count,
              let firstVerse = pages[currentPageIndex].verses.first else {
            return "Quran"
        }
        let surahTranslation = getSurahTranslation(for: getSurahIdFromContext(firstVerse))
        let verseText = String(format: ReadingStrings.verse, firstVerse.verseNumber)
        return "\(surahTranslation) (\(firstVerse.surahTransliteration)) - \(verseText)"
    }

    private func getSurahTranslation(for surahId: Int) -> String {
        // Get the surah translation from the loaded data (respects current language)
        let surahs = goalViewModel.getSurahs()
        if let surah = surahs.first(where: { $0.id == surahId }) {
            return surah.translation ?? surah.transliteration
        }
        return "Surah \(surahId)"
    }

    private func getSurahIdFromContext(_ verseContext: VerseWithContext) -> Int {
        let components = verseContext.id.components(separatedBy: "-")
        if let surahIdString = components.first, let surahId = Int(surahIdString) {
            return surahId
        }
        return 1
    }

    var body: some View {
        ZStack {
            // ChatView light mode background
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top area with close button and metrics
                topBar

                // Metrics card
                VerseMetricsCard(
                    goalViewModel: goalViewModel,
                    sessionManager: sessionManager
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Verse-by-verse paging view
                if !pages.isEmpty {
                    TabView(selection: $currentPageIndex) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            VerseByVerseContentView(
                                page: page,
                                isCurrentPage: index == currentPageIndex
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentPageIndex) { newIndex in
                        handlePageChange(newIndex: newIndex)
                    }

                    // Custom page indicator
                    pageIndicator
                        .padding(.bottom, 20)
                } else {
                    loadingStateView
                }
            }
        }
        .onAppear {
            setupReading()
            sessionManager.goalViewModel = goalViewModel
            sessionManager.startSession()
        }
        .onDisappear {
            endSession()
        }
        .onChange(of: scenePhase) { phase in
            handleScenePhaseChange(phase)
        }
        .onChange(of: isPresented) { presented in
            if !presented {
                endSession()
            }
        }
        .sheet(isPresented: $showVerseNavigation) {
            VerseNavigationPopup(
                surahs: goalViewModel.getSurahs(),
                onNavigate: { surahId, verseId in
                    navigateToVerse(surahId: surahId, verseId: verseId)
                }
            )
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Close button
            Button(action: {
                isPresented = false
            }) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                        .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 4, x: 0, y: 2)

                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.closeButton)
                }
            }

            Spacer()

            // Current surah and verse
            if !pages.isEmpty && currentPageIndex < pages.count {
                Text(currentSurahAndVerse)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(AppColors.VerseByVerse.textAccent)
            }

            Spacer()

            // Pencil icon button for verse navigation
            Button(action: {
                showVerseNavigation = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                        .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 4, x: 0, y: 2)

                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.VerseByVerse.accentGreen)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            // Previous pages indicator
            if currentPageIndex > 0 {
                Text("\(currentPageIndex)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.VerseByVerse.textSecondary)
            }

            // Current page dot
            Circle()
                .fill(AppColors.VerseByVerse.navigationDotActive)
                .frame(width: 10, height: 10)

            // Remaining pages indicator
            if currentPageIndex < pages.count - 1 {
                Text("\(pages.count - currentPageIndex - 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.VerseByVerse.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
                .shadow(color: AppColors.VerseByVerse.shadowPrimary, radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Loading State

    private var loadingStateView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppColors.VerseByVerse.accentGreen)

            Text("Loading Quran...")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundColor(AppColors.VerseByVerse.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Setup

    private func setupReading() {
        let surahs = goalViewModel.getSurahs()
        guard !surahs.isEmpty else { return }

        // Get starting position - prioritize current position (from pencil navigation) over saved position
        if let currentPos = goalViewModel.currentPositionInfo {
            startingPosition = currentPos.absoluteVersePosition
        } else if let lastPosition = goalViewModel.getLastReadPosition() {
            startingPosition = goalViewModel.getAbsolutePosition(
                surahId: lastPosition.surahId,
                verseId: lastPosition.verseId
            )
        } else {
            startingPosition = 0
        }

        // Build pages with one verse per page
        let result = VerseByVersePageBuilder.buildPages(
            from: surahs,
            startingAt: startingPosition
        )
        pages = result.pages
        currentPageIndex = result.startIndex
    }

    // MARK: - Page Tracking Methods

    private func handlePageChange(newIndex: Int) {
        guard newIndex < pages.count else { return }

        let newPage = pages[newIndex]

        // Update reading position
        if let lastVerse = newPage.verses.last {
            goalViewModel.updateCurrentPosition(to: lastVerse.absolutePosition)
        }

        // Provide haptic feedback for page turns
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    // MARK: - Navigation to Specific Verse

    private func navigateToVerse(surahId: Int, verseId: Int) {
        let surahs = goalViewModel.getSurahs()
        guard !surahs.isEmpty else { return }

        // Calculate absolute position
        let absolutePosition = goalViewModel.getAbsolutePosition(surahId: surahId, verseId: verseId)

        // Rebuild pages from new position
        let result = VerseByVersePageBuilder.buildPages(
            from: surahs,
            startingAt: absolutePosition
        )
        pages = result.pages
        currentPageIndex = result.startIndex

        // Update goal position
        goalViewModel.updateCurrentPosition(to: absolutePosition)

        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    // MARK: - Session Management

    private func endSession() {
        guard !pages.isEmpty, currentPageIndex < pages.count else {
            sessionManager.stopSession()
            return
        }

        let currentPage = pages[currentPageIndex]
        let versesRead = currentPage.lastVersePosition - startingPosition + 1

        // Get current surah and verse info
        if let positionInfo = VerseByVersePageBuilder.getPositionInfo(
            for: currentPage.lastVersePosition,
            in: goalViewModel.getSurahs()
        ) {
            sessionManager.endSession(
                versesRead: max(0, versesRead),
                currentSurahId: positionInfo.surahId,
                currentVerseId: positionInfo.verseId
            )
        } else {
            sessionManager.stopSession()
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            sessionManager.pauseSession()
        case .active:
            if isPresented {
                sessionManager.resumeSession()
            }
        @unknown default:
            break
        }
    }
}

// MARK: - Preview

#Preview {
    VerseByVerseReadingPreviewWrapper()
}

struct VerseByVerseReadingPreviewWrapper: View {
    @State private var isPresented = true
    @ObservedObject private var viewModel = ReadingGoalViewModel.shared

    var body: some View {
        VerseByVerseReadingView(
            goalViewModel: viewModel,
            isPresented: $isPresented
        )
    }
}
