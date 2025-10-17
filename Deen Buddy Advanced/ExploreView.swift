//
//  ExploreView.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "safari.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.Explore.icon)
                    .padding()

                Text("Explore")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(AppColors.Explore.secondaryText)
                    .padding(.top, 4)
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
