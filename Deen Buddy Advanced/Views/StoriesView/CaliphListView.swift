//
//  CaliphListView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import SwiftUI

struct CaliphListView: View {
    @StateObject private var vm = CaliphListViewModel()

    var body: some View {
        List {
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
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.countdownBackground)
                    .frame(width: 44, height: 44)
                Text("\(item.caliph.order)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.Prayers.countdownText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.caliph.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(item.isLocked ? .secondary : .primary)
                Text(item.caliph.title)
                    .font(.caption)
                    .foregroundColor(item.isLocked ? .secondary.opacity(0.7) : .secondary)
            }

            Spacer()

            Image(systemName: trailingIconName)
                .foregroundColor(iconColor)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.vertical, 6)
    }

    private var trailingIconName: String {
        if item.isLocked {
            return "lock.fill"
        }
        if item.isCompleted {
            return "checkmark.circle.fill"
        }
        return "chevron.right"
    }

    private var iconColor: Color {
        if item.isLocked {
            return .secondary
        }
        if item.isCompleted {
            return .green
        }
        return .secondary
    }
}
