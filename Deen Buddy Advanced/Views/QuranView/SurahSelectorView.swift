//
//  SurahSelectorView.swift
//  Deen Buddy Advanced
//
//  Surah selection sheet with search
//

import SwiftUI

struct SurahSelectorView: View {
    @ObservedObject var viewModel: QuranViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return viewModel.surahs
        }
        return viewModel.surahs.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.transliteration.localizedCaseInsensitiveContains(searchText) ||
            $0.translation.localizedCaseInsensitiveContains(searchText) ||
            "\($0.id)".contains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredSurahs) { surah in
                    Button(action: {
                        viewModel.goToSurahById(id: surah.id)
                        dismiss()
                    }) {
                        SurahRowView(surah: surah)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Surah...")
            .navigationTitle("Select Surah")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SurahRowView: View {
    let surah: Surah

    var body: some View {
        HStack(spacing: 16) {
            // Surah number badge
            Text("\(surah.id)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.teal]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Surah info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(surah.transliteration)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(surah.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green)
                }

                HStack {
                    Text(surah.translation)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: surah.type == "meccan" ? "moon.fill" : "building.2.fill")
                            .font(.system(size: 10))

                        Text("\(surah.typeCapitalized) • \(surah.total_verses) verses")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SurahSelectorView(viewModel: QuranViewModel())
}
