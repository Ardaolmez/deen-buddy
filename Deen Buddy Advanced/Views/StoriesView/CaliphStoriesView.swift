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
                ForEach(vm.stories) { story in
                    NavigationLink {
                        StoryDetailView(vm: StoryDetailViewModel(story: story))
                    } label: {
                        StoryRow(story: story)
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
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(vm.caliphName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StoryRow: View {
    let story: StoryArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(.primary)

            Text(story.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
