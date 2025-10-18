//
//  PersonalizedLearningCard.swift
//  Deen Buddy Advanced
//
//  Created by Arda Olmez on 2025-10-07.
//

import SwiftUI

struct PersonalizedLearningCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(AppColors.Today.learningIcon)
                Text(AppStrings.common.personalizedLearning)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text(AppStrings.today.continueJourney)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.common.prophetsStories)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Lesson 3 of 12")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    // Start lesson action
                }) {
                    HStack {
                        Text(AppStrings.common.start)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.Today.learningButton)
                    .foregroundColor(AppColors.Today.learningButtonText)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.Today.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
    }
}

#Preview {
    PersonalizedLearningCard()
}
