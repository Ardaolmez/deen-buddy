//
//  CitationPopupView.swift
//  Deen Buddy Advanced
//
//  Simple overlay popup to display Quran verse citations
//

import SwiftUI

struct CitationPopupView: View {
    let citation: Citation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Centered popup card
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text(citation.surah)
                        .font(.system(.headline, design: .serif).weight(.bold))
                        .foregroundColor(Color(red: 0.29, green: 0.55, blue: 0.42))

                    Text("Ayah \(citation.ayah)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Verse text
                ScrollView {
                    Text(citation.text)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(20)
                }
                .frame(maxHeight: 300)

                // Close button
                Button(action: { dismiss() }) {
                    Text("Close")
                        .font(.system(.body, design: .serif).weight(.medium))
                        .foregroundColor(Color(red: 0.29, green: 0.55, blue: 0.42))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .background(Color(.systemGray6))
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .frame(maxWidth: 340)
            .padding(.horizontal, 30)
        }
    }
}
