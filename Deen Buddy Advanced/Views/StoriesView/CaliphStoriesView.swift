//
//  CaliphStoriesView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import SwiftUI

struct CaliphStoriesView: View {
    @StateObject var vm: CaliphStoriesViewModel

    private var completedCount: Int {
        vm.storyItems.filter { $0.isCompleted }.count
    }

    private var unlockedCount: Int {
        vm.storyItems.filter { $0.isUnlocked }.count
    }

    private var progressPercentage: Double {
        guard !vm.storyItems.isEmpty else { return 0 }
        return Double(completedCount) / Double(vm.storyItems.count)
    }

    var body: some View {
        List {
            // Progress Section
            Section {
                VStack(spacing: 14) {
                    // Caliph header with icon
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.Explore.iconBackground)
                                .frame(width: 40, height: 40)
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.Explore.iconForeground)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.caliphName)
                                .font(.system(.body, design: .serif))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.Explore.primaryText)
                            Text(vm.caliphTitle)
                                .font(.caption)
                                .foregroundColor(AppColors.Explore.secondaryText)
                        }

                        Spacer()

                        // Progress badge
                        Text("\(completedCount)/\(vm.storyItems.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.Explore.accentText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppColors.Explore.subtleAccent)
                            )
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.Explore.progressBackground)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.Explore.progressFill)
                                .frame(width: geo.size.width * progressPercentage, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            // Stories Section
            Section {
                ForEach(vm.storyItems) { item in
                    if item.isUnlocked {
                        NavigationLink {
                            StoryDetailView(
                                vm: StoryDetailViewModel(
                                    story: item.article,
                                    globalIndex: item.globalIndex,
                                    totalStories: vm.totalStories,
                                    useUnlockTimer: vm.usesUnlockTimer
                                )
                            )
                        } label: {
                            StoryRow(item: item, nextUnlockDate: vm.nextUnlockDate)
                        }
                    } else {
                        StoryRow(item: item, nextUnlockDate: vm.nextUnlockDate)
                    }
                }
            } header: {
                Text("Stories")
                    .textCase(nil)
                    .font(.system(.subheadline, design: .default))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Explore.secondaryText)
            } footer: {
                if let date = vm.nextUnlockDate {
                    Text("Next story unlocks \(relativeUnlockDescription(for: date)).")
                        .font(.footnote)
                        .foregroundColor(AppColors.Explore.secondaryText)
                        .padding(.top, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(vm.caliphName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.refresh()
        }
    }

    private func relativeUnlockDescription(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private struct StoryRow: View {
    let item: CaliphStoriesViewModel.StoryItem
    let nextUnlockDate: Date?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.article.title)
                    .font(.system(.body, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(item.isUnlocked ? AppColors.Explore.primaryText : AppColors.Explore.locked)

                Text(item.article.subtitle)
                    .font(.subheadline)
                    .foregroundColor(item.isUnlocked ? AppColors.Explore.secondaryText : AppColors.Explore.locked.opacity(0.8))
                    .lineLimit(2)

                if let status = statusLine {
                    HStack(spacing: 4) {
                        Image(systemName: statusIcon)
                            .font(.caption2)
                        Text(status)
                            .font(.caption)
                    }
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(statusBackgroundColor)
                    )
                }
            }

            Spacer()

            // Trailing icon
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.Explore.completed)
                    .font(.system(size: 18, weight: .semibold))
            } else if !item.isUnlocked {
                ZStack {
                    Circle()
                        .fill(AppColors.Explore.locked.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppColors.Explore.locked)
                        .font(.system(size: 11, weight: .semibold))
                }
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.Explore.accentText)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(.vertical, 6)
        .opacity(item.isUnlocked ? 1.0 : 0.65)
    }

    private var statusLine: String? {
        if item.isCompleted {
            return "Completed"
        }
        if item.isUnlocked {
            return nil
        }
        if item.isNextToUnlock, let nextUnlockDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            let relative = formatter.localizedString(for: nextUnlockDate, relativeTo: Date())
            return "Unlocks \(relative)"
        }
        return "Locked"
    }

    private var statusIcon: String {
        if item.isCompleted {
            return "checkmark.circle.fill"
        }
        if !item.isUnlocked {
            return "lock.fill"
        }
        return "clock.fill"
    }

    private var statusColor: Color {
        if item.isCompleted {
            return AppColors.Explore.completed
        }
        return AppColors.Explore.locked
    }

    private var statusBackgroundColor: Color {
        if item.isCompleted {
            return AppColors.Explore.completed.opacity(0.12)
        }
        return AppColors.Explore.locked.opacity(0.12)
    }
}
