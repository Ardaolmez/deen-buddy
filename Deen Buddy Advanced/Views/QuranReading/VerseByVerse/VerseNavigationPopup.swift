//
//  VerseNavigationPopup.swift
//  Deen Buddy Advanced
//
//  Two-step verse navigation popup
//

import SwiftUI

struct VerseNavigationPopup: View {
    @Environment(\.dismiss) private var dismiss
    let surahs: [Surah]
    let onNavigate: (Int, Int) -> Void  // (surahId, verseId)

    @State private var navigationMode: NavigationMode = .surah
    @State private var step: NavigationStep = .surahSelection
    @State private var selectedJuz: Juz?
    @State private var selectedSurah: Surah?
    @State private var juzSearchText = ""
    @State private var surahSearchText = ""
    @State private var verseSearchText = ""

    enum NavigationMode: String, CaseIterable {
        case surah = "surah"
        case juz = "juz"

        var displayName: String {
            switch self {
            case .surah: return AppStrings.reading.surah
            case .juz: return AppStrings.reading.juz
            }
        }
    }

    enum NavigationStep {
        case juzSelection  // Step 1 for Juz mode
        case surahSelection  // Step 1 for Surah mode, Step 2 for Juz mode
        case verseSelection  // Step 2 for Surah mode, Step 3 for Juz mode
    }

    // MARK: - Filtered Results

    var filteredJuz: [Juz] {
        if juzSearchText.isEmpty {
            return Juz.allJuz
        }

        // Search by Juz number
        if let searchNumber = Int(juzSearchText) {
            return Juz.allJuz.filter { $0.id == searchNumber }
        }

        return Juz.allJuz
    }

    var filteredSurahs: [Surah] {
        // First filter by Juz if in Juz mode
        var surahsToFilter = surahs
        if navigationMode == .juz, let juz = selectedJuz {
            surahsToFilter = surahs.filter { surah in
                surah.id >= juz.startSurah && surah.id <= juz.endSurah
            }
        }

        // Then apply search filter
        if surahSearchText.isEmpty {
            return surahsToFilter
        }

        return surahsToFilter.filter { surah in
            // Search by surah number
            if let searchNumber = Int(surahSearchText), surah.id == searchNumber {
                return true
            }

            // Search by transliteration
            if surah.transliteration.localizedCaseInsensitiveContains(surahSearchText) {
                return true
            }

            // Search by translation
            if let translation = surah.translation,
               translation.localizedCaseInsensitiveContains(surahSearchText) {
                return true
            }

            // Search by Arabic name
            if surah.name.contains(surahSearchText) {
                return true
            }

            return false
        }
    }

    var filteredVerses: [Int] {
        guard let surah = selectedSurah else { return [] }

        // Calculate verse range based on Juz boundaries if in Juz mode
        var verseRange: ClosedRange<Int>

        if navigationMode == .juz, let juz = selectedJuz {
            // Determine the verse range for this surah within the Juz
            let startVerse: Int
            let endVerse: Int

            if surah.id == juz.startSurah && surah.id == juz.endSurah {
                // Juz starts and ends in the same surah
                startVerse = juz.startVerse
                endVerse = juz.endVerse
            } else if surah.id == juz.startSurah {
                // This is the starting surah of the Juz
                startVerse = juz.startVerse
                endVerse = surah.verses.count
            } else if surah.id == juz.endSurah {
                // This is the ending surah of the Juz
                startVerse = 1
                endVerse = juz.endVerse
            } else {
                // This surah is completely within the Juz
                startVerse = 1
                endVerse = surah.verses.count
            }

            verseRange = startVerse...endVerse
        } else {
            // Surah mode - show all verses
            verseRange = 1...surah.verses.count
        }

        // Apply search filter on the verse range
        if verseSearchText.isEmpty {
            return Array(verseRange)
        }

        // Search by verse number within the range
        if let searchNumber = Int(verseSearchText) {
            return Array(verseRange).filter { $0 == searchNumber }
        }

        return []
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Surah/Juz toggle - always show EXCEPT during verse selection
                    if step != .verseSelection {
                        navigationModeToggle
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                    }

                    // Show appropriate view based on step
                    switch step {
                    case .juzSelection:
                        juzSelectionView
                    case .surahSelection:
                        surahSelectionView
                    case .verseSelection:
                        verseSelectionView
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(backButtonText) {
                        handleBackButton()
                    }
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var navigationTitle: String {
        switch step {
        case .juzSelection:
            return AppStrings.reading.selectJuz
        case .surahSelection:
            return AppStrings.reading.selectSurah
        case .verseSelection:
            return AppStrings.reading.selectVerse
        }
    }

    private var backButtonText: String {
        switch step {
        case .juzSelection:
            return AppStrings.reading.cancel
        case .surahSelection:
            return navigationMode == .juz ? AppStrings.reading.back : AppStrings.reading.cancel
        case .verseSelection:
            return AppStrings.reading.back
        }
    }

    private func handleBackButton() {
        switch step {
        case .juzSelection:
            dismiss()
        case .surahSelection:
            if navigationMode == .juz {
                withAnimation {
                    step = .juzSelection
                    selectedSurah = nil
                    surahSearchText = ""
                }
            } else {
                dismiss()
            }
        case .verseSelection:
            withAnimation {
                step = .surahSelection
                selectedSurah = nil
                verseSearchText = ""
            }
        }
    }

    // MARK: - Navigation Mode Toggle

    private var navigationModeToggle: some View {
        Picker("Navigation Mode", selection: $navigationMode) {
            ForEach(NavigationMode.allCases, id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: navigationMode) { newMode in
            // Reset and navigate to appropriate first step
            juzSearchText = ""
            surahSearchText = ""
            selectedJuz = nil
            selectedSurah = nil

            withAnimation {
                step = newMode == .juz ? .juzSelection : .surahSelection
            }
        }
    }

    // MARK: - Step 1 (Juz Mode): Juz Selection

    private var juzSelectionView: some View {
        ScrollView {
            if filteredJuz.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding(.top, 60)

                    Text(AppStrings.reading.noResults)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(filteredJuz, id: \.id) { juz in
                        Button(action: {
                            selectedJuz = juz
                            juzSearchText = ""
                            withAnimation {
                                step = .surahSelection
                            }
                        }) {
                        VStack(spacing: 8) {
                            // Juz number circle
                            ZStack {
                                Circle()
                                    .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                                    .frame(width: 60, height: 60)

                                Text("\(juz.id)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppColors.VerseByVerse.accentGreen)
                            }

                            // Juz label
                            Text(String(format: AppStrings.reading.juzFormat, juz.id))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)

                            // Range info
                            Text("\(juz.startSurah):\(juz.startVerse) - \(juz.endSurah):\(juz.endVerse)")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $juzSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: AppStrings.reading.searchJuz)
    }

    // MARK: - Step 1 (Surah Mode) / Step 2 (Juz Mode): Surah Selection

    private var surahSelectionView: some View {
        ScrollView {
            // Show selected Juz header when in Juz mode
            if navigationMode == .juz, let juz = selectedJuz {
                VStack(spacing: 8) {
                    Text(String(format: AppStrings.reading.juzFormat, juz.id))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Text(String(format: AppStrings.reading.surahsRange, juz.startSurah, juz.endSurah))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }

            if filteredSurahs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding(.top, 60)

                    Text(AppStrings.reading.noResults)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filteredSurahs, id: \.id) { surah in
                        Button(action: {
                            selectedSurah = surah
                            surahSearchText = ""
                            withAnimation {
                                step = .verseSelection
                            }
                        }) {
                            HStack(spacing: 16) {
                                // Surah number circle
                                ZStack {
                                    Circle()
                                        .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                                        .frame(width: 44, height: 44)

                                    Text("\(surah.id)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppColors.VerseByVerse.accentGreen)
                                }

                                // Surah name
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(surah.translation ?? surah.transliteration)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(surah.transliteration)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                // Verse count
                                Text(String(format: AppStrings.reading.verseCount, surah.verses.count))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)

                                // Chevron
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $surahSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: AppStrings.reading.searchSurah)
    }

    // MARK: - Step 2: Verse Selection (5 per row grid)

    private var verseSelectionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let surah = selectedSurah {
                    // Surah info header
                    VStack(spacing: 8) {
                        // Show Juz info when in Juz mode
                        if navigationMode == .juz, let juz = selectedJuz {
                            Text(String(format: AppStrings.reading.juzFormat, juz.id))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.VerseByVerse.accentGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppColors.VerseByVerse.accentGreen.opacity(0.1))
                                )
                        }

                        Text(surah.translation ?? surah.transliteration)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)

                        Text(surah.transliteration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(String(format: AppStrings.reading.verseCount, surah.verses.count))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Verse number grid (5 per row)
                    if filteredVerses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                                .padding(.top, 40)

                            Text(AppStrings.reading.noResults)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                            ForEach(filteredVerses, id: \.self) { verseNumber in
                                Button(action: {
                                    onNavigate(surah.id, verseNumber)
                                    dismiss()
                                }) {
                                    Text("\(verseNumber)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(AppColors.VerseByVerse.accentGreen)
                                        .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $verseSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: AppStrings.reading.searchVerse)
    }
}

#Preview {
    VerseNavigationPopup(
        surahs: QuranService.shared.loadQuran(language: .english),
        onNavigate: { surahId, verseId in
            print("Navigate to Surah \(surahId), Verse \(verseId)")
        }
    )
}
