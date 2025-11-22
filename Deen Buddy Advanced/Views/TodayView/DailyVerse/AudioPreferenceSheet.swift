//
//  AudioPreferenceSheet.swift
//  Deen Buddy Advanced
//
//  Bottom sheet for selecting audio playback preference
//  Shown on first Listen tap or when changing settings
//

import SwiftUI

struct AudioPreferenceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let currentPreference: DailyVerseAudioPreference?
    let onSelect: (DailyVerseAudioPreference) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Title
            VStack(spacing: 4) {
                Text("How would you like to listen?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)

                Text("Choose your preferred audio mode")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 24)

            // Options
            VStack(spacing: 12) {
                ForEach(DailyVerseAudioPreference.allCases, id: \.rawValue) { preference in
                    AudioPreferenceOption(
                        preference: preference,
                        isSelected: currentPreference == preference,
                        onTap: {
                            onSelect(preference)
                            dismiss()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Option Row

struct AudioPreferenceOption: View {
    let preference: DailyVerseAudioPreference
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.Prayers.prayerGreen : Color(.systemGray5))
                        .frame(width: 44, height: 44)

                    Image(systemName: preference.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(preference.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(preference.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.Prayers.prayerGreen)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? AppColors.Prayers.prayerGreen : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            AudioPreferenceSheet(
                currentPreference: .arabicOnly,
                onSelect: { _ in }
            )
        }
}
