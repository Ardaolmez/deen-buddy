//
//  PrayersView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct PrayersView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.indigo)
                    .padding()

                Text("Prayers")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .navigationTitle("Prayers")
        }
    }
}

#Preview {
    PrayersView()
}
