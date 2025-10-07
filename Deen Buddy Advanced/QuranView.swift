//
//  QuranView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct QuranView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()

                Text("Quran")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .navigationTitle("Quran")
        }
    }
}

#Preview {
    QuranView()
}
