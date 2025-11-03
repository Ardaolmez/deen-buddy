import SwiftUI

struct ExploreView: View {
    @StateObject private var vm = ExploreViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Caliphate Stories card
                    NavigationLink {
                        CaliphListView()
                    } label: {
                        ExploreCard(
                            icon: "crown.fill",
                            title: "Stories of the Caliphate",
                            subtitle: "Leadership after the Prophet ﷺ",
                            isComingSoon: false
                        )
                    }

                    // Prophet Stories card (placeholder for now)
                    NavigationLink {
                        // TODO: hook up ProphetStoriesListView when you build it
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.Explore.comingSoon)

                            Text(AppStrings.explore.prophetStoriesComingSoon)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text("Stay tuned for inspiring stories from the life of Prophet Muhammad ﷺ")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(40)
                    } label: {
                        ExploreCard(
                            icon: "sparkles",
                            title: "Stories of the Prophet ﷺ",
                            subtitle: "Miracles, mercy, and guidance",
                            isComingSoon: true
                        )
                    }
                    .disabled(true)

                    // (Optional) More sections later like featured story, etc.
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .navigationTitle(AppStrings.explore.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ExploreCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isComingSoon: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top section with icon and badge
            HStack {
                // Icon bubble
                ZStack {
                    Circle()
                        .fill(isComingSoon ? AppColors.Explore.comingSoon.opacity(0.12) : AppColors.Explore.iconBackground)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundStyle(isComingSoon ? AppColors.Explore.comingSoon : AppColors.Explore.iconForeground)
                        .font(.system(size: 18, weight: .semibold))
                }

                Spacer()

                // Coming Soon badge
                if isComingSoon {
                    Text("Coming Soon")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.Explore.comingSoon)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.Explore.comingSoon.opacity(0.12))
                        )
                }
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(isComingSoon ? AppColors.Explore.comingSoon : AppColors.Explore.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(isComingSoon ? AppColors.Explore.comingSoon.opacity(0.8) : AppColors.Explore.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            // Bottom action
            if !isComingSoon {
                HStack(spacing: 4) {
                    Text(AppStrings.explore.view)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(AppColors.Explore.accentText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.Explore.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppColors.Explore.subtleBorder, lineWidth: 1)
                )
                .shadow(color: AppColors.Explore.cardShadow,
                        radius: 10, x: 0, y: 4)
        )
        .opacity(isComingSoon ? 0.7 : 1.0)
    }
}
