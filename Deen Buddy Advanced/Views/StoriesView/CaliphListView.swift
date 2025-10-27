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
                ForEach(vm.caliphs) { caliph in
                    NavigationLink {
                        CaliphStoriesView(vm: CaliphStoriesViewModel(caliph: caliph))
                    } label: {
                        CaliphRow(caliph: caliph)
                    }
                }
            } header: {
                Text("Rightly Guided Caliphs")
                    .textCase(nil)
                    .font(.system(.headline, design: .serif))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Caliphate")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CaliphRow: View {
    let caliph: Caliph

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.Prayers.countdownBackground)
                    .frame(width: 44, height: 44)
                Text("\(caliph.order)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.Prayers.countdownText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(caliph.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(.primary)
                Text(caliph.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.vertical, 6)
    }
}
