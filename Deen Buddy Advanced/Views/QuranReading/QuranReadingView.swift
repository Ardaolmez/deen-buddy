//
//  QuranReadingView.swift
//  Deen Buddy Advanced
//
//  Main view for Quran reading with horizontal page swiping
//

import SwiftUI

struct QuranReadingView: View {
    @ObservedObject var goalViewModel: ReadingGoalViewModel
    @Binding var isPresented: Bool
    @StateObject private var sessionManager = ReadingSessionManager()
    @StateObject private var screenManager = ScreenDimensionManager.shared
    @Environment(\.scenePhase) private var scenePhase

    @State private var pages: [QuranReadingPage] = []
    @State private var currentPageIndex: Int = 0
    @State private var startingPosition: Int = 0
    @State private var versesReadThisSession: Int = 0
    @State private var showReadingMetrics: Bool = false

    var currentSurahName: String {
        guard !pages.isEmpty,
              currentPageIndex < pages.count,
              let firstVerse = pages[currentPageIndex].verses.first else {
            return "Quran"
        }
        return firstVerse.surahTransliteration
    }

    var body: some View {
        ZStack {
            // Enhanced background with gradient
            AppColors.Reading.pageCardBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Simple header with close button and page info
                simpleHeader

                // Reading metrics
                ReadingMetricsView(
                    sessionManager: sessionManager,
                    goalViewModel: goalViewModel
                )

                // Horizontal paging view with adaptive sizing
                if !pages.isEmpty {
                    TabView(selection: $currentPageIndex) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            EnhancedReadingPageContentView(
                                page: page,
                                isCurrentPage: index == currentPageIndex,
                                pageConfiguration: screenManager.getOptimalPageConfiguration()
                            )
                            .tag(index)
                            .onAppear {
                                trackPageView(page: page)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentPageIndex) { newIndex in
                        handlePageChange(newIndex: newIndex)
                    }
                } else {
                    // Enhanced loading state
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
    }

    // MARK: - Simple Header

    private var simpleHeader: some View {
        HStack {
            // Close button
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.Reading.darkBackgroundTop)
            }

            Spacer()

            // Page info with surah name
            if !pages.isEmpty && currentPageIndex < pages.count {
                let currentPage = pages[currentPageIndex]
                if let firstVerse = currentPage.verses.first {
                    VStack(spacing: 2) {
                        Text("Page \(currentPageIndex + 1) of \(pages.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.Reading.metricsSecondary)

                        Text(firstVerse.surahTransliteration)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.Reading.darkBackgroundTop)
                    }
                }
            }

            Spacer()

            // Placeholder for balance
            Color.clear
                .frame(width: 18, height: 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(AppColors.Reading.pageCenter)
    }

    // MARK: - Enhanced Loading State

    private var loadingStateView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Quran...")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundColor(AppColors.Reading.metricsText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.Reading.pageCenter)
    }

    // MARK: - Setup

    private func setupReading() {
        let surahs = goalViewModel.getSurahs()
        guard !surahs.isEmpty else { return }

        // Get starting position
        if let lastPosition = goalViewModel.getLastReadPosition() {
            startingPosition = goalViewModel.getAbsolutePosition(
                surahId: lastPosition.surahId,
                verseId: lastPosition.verseId
            )
        } else if let currentPos = goalViewModel.currentPositionInfo {
            startingPosition = currentPos.absoluteVersePosition
        } else {
            startingPosition = 0
        }

        // Build pages with adaptive sizing
        let pageConfig = screenManager.getOptimalPageConfiguration()
        let result = QuranPageBuilder.buildAdaptivePages(
            from: surahs,
            startingAt: startingPosition,
            versesPerPage: pageConfig.versesPerPage
        )
        pages = result.pages
        currentPageIndex = result.startIndex
    }

    // MARK: - Page Tracking Methods

    private func trackPageView(page: QuranReadingPage) {
        // Track verses viewed for analytics
        let versesOnPage = page.verses.count
        versesReadThisSession += versesOnPage
    }

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

    // MARK: - Session Management

    private func endSession() {
        guard !pages.isEmpty, currentPageIndex < pages.count else {
            sessionManager.stopSession()
            return
        }

        let currentPage = pages[currentPageIndex]
        let versesRead = currentPage.lastVersePosition - startingPosition + 1

        // Get current surah and verse info
        if let positionInfo = QuranPageBuilder.getPositionInfo(
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

#Preview {
    QuranReadingPreviewWrapper()
}

struct QuranReadingPreviewWrapper: View {
    @State private var isPresented = true
    @StateObject private var viewModel = ReadingGoalViewModel()

    var body: some View {
        QuranReadingView(
            goalViewModel: viewModel,
            isPresented: $isPresented
        )
    }
}
