//
//  BookmarksListView.swift
//  Deen Buddy Advanced
//
//  Two-step view for browsing bookmark folders and their verses
//

import SwiftUI

struct BookmarksListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var bookmarksManager = BookmarksManager.shared
    @ObservedObject private var quranViewModel = QuranViewModel()

    @State private var step: BookmarkStep = .folderSelection
    @State private var selectedFolder: BookmarkFolder?
    @State private var folderSearchText = ""
    @State private var verseSearchText = ""
    @State private var showCreateFolder = false
    @State private var showDeleteConfirmation = false
    @State private var showRenameFolder = false
    @State private var selectedVerse: VerseSelection?

    // Identifiable wrapper for verse selection
    struct VerseSelection: Identifiable {
        let id = UUID()
        let surahName: String
        let verseNumber: Int
    }

    enum BookmarkStep {
        case folderSelection
        case verseList
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    switch step {
                    case .folderSelection:
                        folderSelectionView
                    case .verseList:
                        verseListView
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

                // Show folder actions when a folder is selected
                if step == .verseList, selectedFolder != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { showRenameFolder = true }) {
                                Label(AppStrings.quran.rename, systemImage: "pencil")
                            }

                            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                                Label(AppStrings.quran.delete, systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateFolder) {
                CreateFolderSheet(onCreate: { name in
                    bookmarksManager.createFolder(name: name)
                    showCreateFolder = false
                })
            }
            .sheet(isPresented: $showRenameFolder) {
                if let folder = selectedFolder {
                    RenameFolderSheet(currentName: folder.name, onRename: { newName in
                        bookmarksManager.renameFolder(withId: folder.id, newName: newName)
                        showRenameFolder = false
                    })
                }
            }
            .sheet(item: $selectedVerse) { selected in
                VersePopupView(
                    surahName: selected.surahName,
                    verseNumber: selected.verseNumber
                )
            }
            .alert(AppStrings.quran.deleteFolderConfirmation, isPresented: $showDeleteConfirmation) {
                Button(AppStrings.quran.cancel, role: .cancel) {}
                Button(AppStrings.quran.deleteConfirm, role: .destructive) {
                    if let folder = selectedFolder {
                        bookmarksManager.deleteFolder(withId: folder.id)
                        withAnimation {
                            step = .folderSelection
                            selectedFolder = nil
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var navigationTitle: String {
        switch step {
        case .folderSelection:
            return AppStrings.quran.bookmarks
        case .verseList:
            return selectedFolder?.name ?? AppStrings.quran.bookmarks
        }
    }

    private var backButtonText: String {
        switch step {
        case .folderSelection:
            return AppStrings.quran.done
        case .verseList:
            return AppStrings.quran.back
        }
    }

    private func handleBackButton() {
        switch step {
        case .folderSelection:
            dismiss()
        case .verseList:
            withAnimation {
                step = .folderSelection
                selectedFolder = nil
                verseSearchText = ""
            }
        }
    }

    // MARK: - Folder Selection View

    private var folderSelectionView: some View {
        ZStack {
            if bookmarksManager.folders.isEmpty {
                emptyFoldersView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Add New Folder button at top
                        Button(action: { showCreateFolder = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(AppColors.Prayers.prayerGreen)

                                Text(AppStrings.quran.addNewFolder)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.Prayers.prayerGreen)

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.Prayers.prayerGreen.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.Prayers.prayerGreen.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Folders list
                        ForEach(filteredFolders) { folder in
                            Button(action: {
                                selectedFolder = folder
                                folderSearchText = ""
                                withAnimation {
                                    step = .verseList
                                }
                            }) {
                                FolderRow(folder: folder)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .searchable(text: $folderSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search folders...")
            }
        }
    }

    private var emptyFoldersView: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text(AppStrings.quran.noBookmarksYet)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)

                Text(AppStrings.quran.createFolderToOrganize)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Add first folder button
            Button(action: { showCreateFolder = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text(AppStrings.quran.addNewFolder)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppColors.Prayers.prayerGreen)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Verse List View

    private var verseListView: some View {
        ZStack {
            if let folder = selectedFolder, folder.verses.isEmpty {
                emptyVersesView
            } else if let folder = selectedFolder {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredVerses(in: folder)) { verse in
                            if let surah = getSurah(id: verse.surahId),
                               let verseData = getVerse(surahId: verse.surahId, verseId: verse.verseId) {
                                BookmarkedVerseRow(
                                    surah: surah,
                                    verseId: verse.verseId,
                                    verseText: verseData.text,
                                    verseTranslation: verseData.translation,
                                    onDelete: {
                                        bookmarksManager.removeVerseFromFolder(folderId: folder.id, verseId: verse.id)
                                    },
                                    onTap: {
                                        selectedVerse = VerseSelection(
                                            surahName: surah.transliteration,
                                            verseNumber: verse.verseId
                                        )
                                    }
                                )

                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .searchable(text: $verseSearchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search verses...")
            }
        }
    }

    private var emptyVersesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(AppStrings.quran.noVersesInFolder)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Text(AppStrings.quran.addVersesWhileReading)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Filtered Results

    private var filteredFolders: [BookmarkFolder] {
        let folders = bookmarksManager.getFolders()

        if folderSearchText.isEmpty {
            return folders
        }

        return folders.filter { folder in
            folder.name.localizedCaseInsensitiveContains(folderSearchText)
        }
    }

    private func filteredVerses(in folder: BookmarkFolder) -> [BookmarkedVerse] {
        if verseSearchText.isEmpty {
            return folder.verses.sorted { $0.addedAt > $1.addedAt }
        }

        return folder.verses.filter { verse in
            // Search by verse reference
            if verse.verseReference.contains(verseSearchText) {
                return true
            }

            // Search by surah name
            if let surah = getSurah(id: verse.surahId) {
                if surah.transliteration.localizedCaseInsensitiveContains(verseSearchText) {
                    return true
                }
                if let translation = surah.translation,
                   translation.localizedCaseInsensitiveContains(verseSearchText) {
                    return true
                }
            }

            return false
        }.sorted { $0.addedAt > $1.addedAt }
    }

    // MARK: - Helper Methods

    private func getSurah(id: Int) -> Surah? {
        return quranViewModel.surahs.first { $0.id == id }
    }

    private func getVerse(surahId: Int, verseId: Int) -> Verse? {
        guard let surah = getSurah(id: surahId),
              verseId > 0 && verseId <= surah.verses.count else {
            return nil
        }
        return surah.verses[verseId - 1]
    }
}

// MARK: - Folder Row

struct FolderRow: View {
    let folder: BookmarkFolder

    var body: some View {
        HStack(spacing: 16) {
            // Folder icon
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.prayerGreen.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: "folder.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.Prayers.prayerGreen)
            }

            // Folder info
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                Text(folder.verseCount == 1 ?
                     String(format: AppStrings.quran.verseInFolder, folder.verseCount) :
                     String(format: AppStrings.quran.versesInFolder, folder.verseCount))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Bookmarked Verse Row

struct BookmarkedVerseRow: View {
    let surah: Surah
    let verseId: Int
    let verseText: String
    let verseTranslation: String?
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Verse reference circle
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.prayerGreen.opacity(0.1))
                    .frame(width: 44, height: 44)

                VStack(spacing: 2) {
                    Text("\(surah.id)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.Prayers.prayerGreen)

                    Text("\(verseId)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                }
            }

            // Verse content
            VStack(alignment: .leading, spacing: 8) {
                // Surah name - Transliteration and English
                HStack(spacing: 8) {
                    Text(surah.transliteration)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    if let translation = surah.translation {
                        Text("•")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)

                        Text(translation)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }

                // Arabic text (preview)
                Text(verseText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Translation (preview)
                if let translation = verseTranslation {
                    Text(translation)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.Prayers.prayerGreen)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Create Folder Sheet

struct CreateFolderSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onCreate: (String) -> Void

    @State private var folderName = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(AppStrings.quran.enterFolderName, text: $folderName)
                }
            }
            .navigationTitle(AppStrings.quran.addNewFolder)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.quran.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quran.create) {
                        let trimmedName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            onCreate(trimmedName)
                        }
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Rename Folder Sheet

struct RenameFolderSheet: View {
    @Environment(\.dismiss) private var dismiss
    let currentName: String
    let onRename: (String) -> Void

    @State private var folderName = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(AppStrings.quran.enterFolderName, text: $folderName)
                }
            }
            .navigationTitle(AppStrings.quran.rename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(AppStrings.quran.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quran.done) {
                        let trimmedName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            onRename(trimmedName)
                        }
                    }
                    .disabled(folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                folderName = currentName
            }
        }
    }
}

#Preview {
    BookmarksListView()
}
