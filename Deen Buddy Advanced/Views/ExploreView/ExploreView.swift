import SwiftUI

struct ExploreView: View {
    @StateObject private var vm = ExploreViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Grid of 2 cards
                    HStack(spacing: 16) {
                        // Prophet Stories card (placeholder for now)
                        NavigationLink {
                            // TODO: hook up ProphetStoriesListView when you build it
                            Text(AppStrings.explore.prophetStoriesComingSoon)
                                .font(.headline)
                                .padding()
                        } label: {
                            ExploreCard(
                                icon: "sparkles",
                                title: "Stories of the Prophet ﷺ",
                                subtitle: "Miracles, mercy, and guidance"
                            )
                        }

                        // Caliphate Stories card
                        NavigationLink {
                            CaliphListView()
                        } label: {
                            ExploreCard(
                                icon: "crown.fill",
                                title: "Stories of the Caliphate",
                                subtitle: "Leadership after the Prophet ﷺ"
                            )
                        }
                    }
                    .padding(.horizontal)

                    // (Optional) More sections later like featured story, etc.
                }
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // icon bubble
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.countdownBackground)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .foregroundStyle(AppColors.Prayers.countdownText)
                    .font(.system(size: 16, weight: .semibold))
            }

            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Text(AppStrings.explore.view)
                    .font(.caption)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(AppColors.Prayers.countdownText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.Prayers.cardBackground)
                .shadow(color: AppColors.Prayers.headerShadow.opacity(0.4),
                        radius: 8, x: 0, y: 4)
        )
    }
}
