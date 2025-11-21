//
//  AddToBookmarkPopup.swift
//  Deen Buddy Advanced
//
//  Popup for adding a verse to bookmark folders
//

import SwiftUI

struct AddToBookmarkPopup: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var bookmarksManager = BookmarksManager.shared

    let surahId: Int
    let verseId: Int

    @State private var showCreateFolder = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                if bookmarksManager.folders.isEmpty {
                    emptyStateView
                } else {
                    foldersList
                }
            }
            .navigationTitle(AppStrings.quran.addToBookmark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(AppStrings.quran.done) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCreateFolder) {
                CreateFolderSheet(onCreate: { name in
                    bookmarksManager.createFolder(name: name)
                    showCreateFolder = false
                })
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
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

            // Create first folder button
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

    // MARK: - Folders List

    private var foldersList: some View {
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

                // Existing folders list
                ForEach(filteredFolders) { folder in
                    Button(action: {
                        addVerseToFolder(folder: folder)
                    }) {
                        SelectableFolderRow(
                            folder: folder,
                            isSelected: bookmarksManager.isVerseInFolder(
                                folderId: folder.id,
                                surahId: surahId,
                                verseId: verseId
                            )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: AppStrings.quran.searchFolders)
    }

    // MARK: - Filtered Results

    private var filteredFolders: [BookmarkFolder] {
        let folders = bookmarksManager.getFolders()

        if searchText.isEmpty {
            return folders
        }

        return folders.filter { folder in
            folder.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Actions

    private func addVerseToFolder(folder: BookmarkFolder) {
        let isAlreadyInFolder = bookmarksManager.isVerseInFolder(
            folderId: folder.id,
            surahId: surahId,
            verseId: verseId
        )

        if isAlreadyInFolder {
            // Remove from folder
            bookmarksManager.removeVerseFromFolder(
                folderId: folder.id,
                surahId: surahId,
                verseId: verseId
            )
        } else {
            // Add to folder
            bookmarksManager.addVerseToFolder(
                folderId: folder.id,
                surahId: surahId,
                verseId: verseId
            )
        }
    }
}

// MARK: - Selectable Folder Row

struct SelectableFolderRow: View {
    let folder: BookmarkFolder
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Folder icon
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.prayerGreen.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: "folder.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerGreen.opacity(0.6))
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

            // Checkmark
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(AppColors.Prayers.prayerGreen)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? AppColors.Prayers.prayerGreen.opacity(0.05) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColors.Prayers.prayerGreen : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
        )
    }
}

#Preview {
    AddToBookmarkPopup(surahId: 1, verseId: 1)
}
