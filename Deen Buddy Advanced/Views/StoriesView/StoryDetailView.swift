//
//  StoryDetailView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import SwiftUI

struct StoryDetailView: View {
    @StateObject var vm: StoryDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title / subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text(vm.story.title)
                        .font(.system(.title2, design: .serif).weight(.semibold))

                    Text(vm.story.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Intro card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    Text(vm.story.intro)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.Prayers.cardBackground)
                        .shadow(color: AppColors.Prayers.headerShadow.opacity(0.2),
                                radius: 8, x: 0, y: 4)
                )

                // Sections
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(vm.story.sections) { section in
                        SectionBlock(section: section)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    if vm.isCompleted {
                        Label {
                            Text("Marked as read")
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.green)

                        if let date = vm.nextUnlockDate {
                            Text("Next story unlocks \(relativeUnlockDescription(for: date)).")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button {
                            vm.markAsRead()
                        } label: {
                            Label("Mark as Read", systemImage: "bookmark.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!vm.canMarkAsRead)

                        if !vm.canMarkAsRead {
                            Text("Only the most recent unlocked story can be marked as read.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationTitle(vm.story.title)
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

private struct SectionBlock: View {
    let section: StorySection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(section.heading)
                .font(.system(.headline, design: .serif))
                .foregroundColor(.primary)

            if section.isBullets {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(section.paragraphs.indices, id: \.self) { idx in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(AppColors.Prayers.countdownText)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            Text(section.paragraphs[idx])
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(section.paragraphs, id: \.self) { para in
                        Text(para)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
