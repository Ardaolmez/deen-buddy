//
//  CaliphListView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import SwiftUI

struct CaliphListView: View {
    @StateObject private var vm = CaliphListViewModel()

    private var completedCount: Int {
        vm.items.filter { $0.isCompleted }.count
    }

    private var unlockedCount: Int {
        vm.items.filter { !$0.isLocked }.count
    }

    private var progressPercentage: Double {
        guard !vm.items.isEmpty else { return 0 }
        return Double(completedCount) / Double(vm.items.count)
    }

    var body: some View {
        List {
            // Progress Section
            Section {
                VStack(spacing: 16) {
                    // Progress stats
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.Explore.iconForeground)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Progress")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.Explore.primaryText)

                            Text("\(completedCount) of \(vm.items.count) completed")
                                .font(.caption)
                                .foregroundColor(AppColors.Explore.secondaryText)
                        }

                        Spacer()

                        // Percentage badge
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.Explore.accentText)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.Explore.progressBackground)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppColors.Explore.progressFill)
                                .frame(width: geo.size.width * progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            // Caliphs List Section
            Section {
                ForEach(vm.items) { item in
                    NavigationLink {
                        CaliphStoriesView(vm: CaliphStoriesViewModel(caliph: item.caliph,
                                                                     useUnlockTimer: vm.usesUnlockTimer))
                    } label: {
                        CaliphRow(item: item)
                    }
                    .disabled(item.isLocked)
                }
            } header: {
                Text("Rightly Guided Caliphs")
                    .textCase(nil)
                    .font(.system(.headline, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Explore.primaryText)
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
        .navigationTitle("Caliphate")
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

private struct CaliphRow: View {
    let item: CaliphListViewModel.CaliphListItem

    var body: some View {
        HStack(spacing: 14) {
            // Numbered badge
            ZStack {
                Circle()
                    .fill(badgeBackgroundColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(badgeBorderColor, lineWidth: 2)
                    )
                Text("\(item.caliph.order)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(badgeTextColor)
            }

            // Name and title
            VStack(alignment: .leading, spacing: 4) {
                Text(item.caliph.name)
                    .font(.system(.body, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundColor(item.isLocked ? AppColors.Explore.locked : AppColors.Explore.primaryText)

                Text(item.caliph.title)
                    .font(.subheadline)
                    .foregroundColor(item.isLocked ? AppColors.Explore.locked.opacity(0.7) : AppColors.Explore.secondaryText)
            }

            Spacer()

            // Trailing icon/badge
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.Explore.completed)
                    .font(.system(size: 20, weight: .semibold))
            } else if item.isLocked {
                ZStack {
                    Circle()
                        .fill(AppColors.Explore.locked.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppColors.Explore.locked)
                        .font(.system(size: 12, weight: .semibold))
                }
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.Explore.accentText)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.vertical, 8)
        .opacity(item.isLocked ? 0.6 : 1.0)
    }

    private var badgeBackgroundColor: Color {
        if item.isCompleted {
            return AppColors.Explore.completed.opacity(0.15)
        } else if item.isLocked {
            return AppColors.Explore.locked.opacity(0.1)
        } else {
            return AppColors.Explore.iconBackground
        }
    }

    private var badgeBorderColor: Color {
        if item.isCompleted {
            return AppColors.Explore.completed.opacity(0.3)
        } else if item.isLocked {
            return AppColors.Explore.locked.opacity(0.2)
        } else {
            return AppColors.Explore.iconForeground.opacity(0.3)
        }
    }

    private var badgeTextColor: Color {
        if item.isCompleted {
            return AppColors.Explore.completed
        } else if item.isLocked {
            return AppColors.Explore.locked
        } else {
            return AppColors.Explore.iconForeground
        }
    }
}
