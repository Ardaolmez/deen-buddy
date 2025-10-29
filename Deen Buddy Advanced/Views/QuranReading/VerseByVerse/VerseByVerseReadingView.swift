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
    @StateObject private var sessionManager = ReadingSessionManager()
    @Environment(\.scenePhase) private var scenePhase

    @State private var pages: [QuranReadingPage] = []
    @State private var currentPageIndex: Int = 0
    @State private var startingPosition: Int = 0

    var currentSurahAndVerse: String {
        guard !pages.isEmpty,
              currentPageIndex < pages.count,
              let firstVerse = pages[currentPageIndex].verses.first else {
            return "Quran"
        }
        let surahEnglishName = getSurahEnglishName(for: getSurahIdFromContext(firstVerse))
        return "\(surahEnglishName) (\(firstVerse.surahTransliteration)) - Verse \(firstVerse.verseNumber)"
    }

    private func getSurahEnglishName(for surahId: Int) -> String {
        let surahNames = [
            1: "The Opening", 2: "The Cow", 3: "The Family of Imran", 4: "The Women",
            5: "The Table", 6: "The Cattle", 7: "The Heights", 8: "The Spoils of War",
            9: "The Repentance", 10: "Jonah", 11: "Hud", 12: "Joseph",
            13: "The Thunder", 14: "Abraham", 15: "The Rocky Tract", 16: "The Bees",
            17: "The Night Journey", 18: "The Cave", 19: "Mary", 20: "Ta-Ha",
            21: "The Prophets", 22: "The Pilgrimage", 23: "The Believers", 24: "The Light",
            25: "The Criterion", 26: "The Poets", 27: "The Ants", 28: "The Stories",
            29: "The Spider", 30: "The Romans", 31: "Luqman", 32: "The Prostration",
            33: "The Combined Forces", 34: "Sheba", 35: "The Originator", 36: "Ya-Sin",
            37: "Those Ranged in Ranks", 38: "Sad", 39: "The Groups", 40: "The Forgiver",
            41: "Distinguished", 42: "The Consultation", 43: "The Gold", 44: "The Smoke",
            45: "The Kneeling", 46: "The Valley", 47: "Muhammad", 48: "The Victory",
            49: "The Dwellings", 50: "Qaf", 51: "The Scatterers", 52: "The Mount",
            53: "The Star", 54: "The Moon", 55: "The Most Gracious", 56: "The Event",
            57: "The Iron", 58: "The Reasoning", 59: "The Gathering", 60: "The Tested",
            61: "The Ranks", 62: "Friday", 63: "The Hypocrites", 64: "The Loss & Gain",
            65: "The Divorce", 66: "The Prohibition", 67: "The Kingdom", 68: "The Pen",
            69: "The Inevitable", 70: "The Levels", 71: "Noah", 72: "The Jinn",
            73: "The Wrapped", 74: "The Covered", 75: "The Resurrection", 76: "The Human",
            77: "Those Sent", 78: "The Great News", 79: "Those Who Pull", 80: "He Frowned",
            81: "The Overthrowing", 82: "The Cleaving", 83: "The Defrauders", 84: "The Splitting",
            85: "The Stars", 86: "The Nightcomer", 87: "The Most High", 88: "The Overwhelming",
            89: "The Dawn", 90: "The City", 91: "The Sun", 92: "The Night",
            93: "The Forenoon", 94: "The Opening-Up", 95: "The Fig", 96: "The Clot",
            97: "The Night of Decree", 98: "The Clear Evidence", 99: "The Earthquake", 100: "The Runners",
            101: "The Striking Hour", 102: "The Piling Up", 103: "The Time", 104: "The Slanderer",
            105: "The Elephant", 106: "Quraish", 107: "The Small Kindnesses", 108: "The River in Paradise",
            109: "The Disbelievers", 110: "The Help", 111: "The Palm Fiber", 112: "The Sincerity",
            113: "The Daybreak", 114: "The People"
        ]
        return surahNames[surahId] ?? "Unknown"
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
                            .onAppear {
                                trackPageView(page: page)
                            }
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

            // Placeholder for balance
            Color.clear
                .frame(width: 40, height: 40)
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

        // Build pages with one verse per page
        let result = VerseByVersePageBuilder.buildPages(
            from: surahs,
            startingAt: startingPosition
        )
        pages = result.pages
        currentPageIndex = result.startIndex
    }

    // MARK: - Page Tracking Methods

    private func trackPageView(page: QuranReadingPage) {
        // Track verse viewed for analytics
        // Each page has exactly one verse in verse-by-verse mode
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
    @StateObject private var viewModel = ReadingGoalViewModel()

    var body: some View {
        VerseByVerseReadingView(
            goalViewModel: viewModel,
            isPresented: $isPresented
        )
    }
}
