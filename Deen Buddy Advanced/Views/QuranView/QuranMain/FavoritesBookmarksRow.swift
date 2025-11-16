//
//  FavoritesBookmarksRow.swift
//  Deen Buddy Advanced
//
//  Quick access row for Favorites and Bookmarks
//

import SwiftUI

struct FavoritesBookmarksRow: View {
    let onFavoritesTapped: () -> Void
    let onBookmarksTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Favorites capsule
            Button(action: onFavoritesTapped) {
                HStack(spacing: 8) {
                    // Heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.Prayers.prayerGreen)

                    // Label
                    Text(AppStrings.quran.favorites)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(AppColors.Quran.papyrusSquare)
                        .shadow(color: AppColors.Prayers.prayerGreen, radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Bookmarks capsule
            Button(action: onBookmarksTapped) {
                HStack(spacing: 8) {
                    // Bookmark icon
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.Prayers.prayerGreen)

                    // Label
                    Text(AppStrings.quran.bookmarks)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(AppColors.Quran.papyrusSquare)
                        .shadow(color: AppColors.Prayers.prayerGreen, radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    FavoritesBookmarksRow(
        onFavoritesTapped: { print("Favorites tapped") },
        onBookmarksTapped: { print("Bookmarks tapped") }
    )
    .padding()
    .background(Color(.systemBackground))
}
