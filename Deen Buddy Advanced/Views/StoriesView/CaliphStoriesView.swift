//
//  CaliphStoriesView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import SwiftUI

struct CaliphStoriesView: View {
    @StateObject var vm: CaliphStoriesViewModel

    var body: some View {
        List {
            Section {
                ForEach(vm.storyItems) { item in
                    if item.isUnlocked {
                        NavigationLink {
                            StoryDetailView(
                                vm: StoryDetailViewModel(
                                    story: item.article,
                                    globalIndex: item.globalIndex,
                                    totalStories: vm.totalStories
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
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.caliphName)
                        .font(.system(.headline, design: .serif))
                    Text(vm.caliphTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .textCase(nil)
            } footer: {
                if let date = vm.nextUnlockDate {
                    Text("Next story unlocks \(relativeUnlockDescription(for: date)).")
                        .font(.footnote)
                        .foregroundColor(.secondary)
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
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.article.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(item.isUnlocked ? .primary : .secondary)

                Text(item.article.subtitle)
                    .font(.caption)
                    .foregroundColor(item.isUnlocked ? .secondary : .secondary.opacity(0.7))
                    .lineLimit(2)

                if let status = statusLine {
                    Text(status)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(statusColor)
                }
            }

            Spacer()

            Image(systemName: trailingIconName)
                .foregroundColor(iconColor)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 4)
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
            formatter.unitsStyle = .spellOut
            let relative = formatter.localizedString(for: nextUnlockDate, relativeTo: Date())
            return "Unlocks \(relative)"
        }
        return "Locked"
    }

    private var statusColor: Color {
        if item.isCompleted {
            return .green
        }
        return .secondary
    }

    private var trailingIconName: String {
        if item.isCompleted {
            return "checkmark.circle.fill"
        }
        if item.isUnlocked {
            return "chevron.right"
        }
        return "lock.fill"
    }

    private var iconColor: Color {
        if item.isCompleted {
            return .green
        }
        return .secondary
    }
}
