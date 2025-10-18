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

                Text(AppStrings.explore.navigationTitle)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(AppStrings.explore.comingSoon)
                    .font(.subheadline)
                    .foregroundColor(AppColors.Explore.secondaryText)
                    .padding(.top, 4)
            }
            .navigationTitle(AppStrings.explore.navigationTitle)
        }
    }
}

#Preview {
    ExploreView()
}
