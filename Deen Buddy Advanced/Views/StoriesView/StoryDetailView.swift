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
            VStack(alignment: .leading, spacing: 24) {
                // Title / subtitle
                VStack(alignment: .leading, spacing: 10) {
                    Text(vm.story.title)
                        .font(.system(.title, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.Explore.primaryText)

                    Text(vm.story.subtitle)
                        .font(.body)
                        .foregroundColor(AppColors.Explore.secondaryText)
                        .lineSpacing(2)
                }

                // Intro card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.Explore.accentText)
                        Text("Overview")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.Explore.accentText)
                    }

                    Text(vm.story.intro)
                        .font(.body)
                        .foregroundColor(AppColors.Explore.primaryText)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.Explore.subtleAccent)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.Explore.accent.opacity(0.2), lineWidth: 1)
                        )
                )

                // Sections
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(vm.story.sections) { section in
                        SectionBlock(section: section)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Completion section
                VStack(alignment: .leading, spacing: 16) {
                    if vm.isCompleted {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.Explore.completed)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Story Completed")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.Explore.primaryText)

                                if let date = vm.nextUnlockDate {
                                    Text("Next story unlocks \(relativeUnlockDescription(for: date))")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.Explore.secondaryText)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppColors.Explore.completed.opacity(0.1))
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                vm.markAsRead()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Mark as Read")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.Explore.accent)
                            .disabled(!vm.canMarkAsRead)

                            if !vm.canMarkAsRead {
                                Text("Only the most recent unlocked story can be marked as read.")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.Explore.secondaryText)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 28)
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
        VStack(alignment: .leading, spacing: 14) {
            // Section heading
            Text(section.heading)
                .font(.system(.title3, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(AppColors.Explore.primaryText)

            if section.isBullets {
                // Bulleted list
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(section.paragraphs.indices, id: \.self) { idx in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.Explore.iconBackground)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(AppColors.Explore.iconForeground)
                                    .frame(width: 4, height: 4)
                            }
                            .padding(.top, 7)

                            Text(section.paragraphs[idx])
                                .font(.body)
                                .foregroundColor(AppColors.Explore.primaryText)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            } else {
                // Regular paragraphs
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(section.paragraphs, id: \.self) { para in
                        Text(para)
                            .font(.body)
                            .foregroundColor(AppColors.Explore.primaryText)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
