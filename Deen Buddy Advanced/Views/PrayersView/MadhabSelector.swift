//
//  MadhabSelector.swift
//  Deen Buddy Advanced
//
//  UI component for selecting prayer calculation madhab
//

import SwiftUI

struct MadhabSelector: View {
    @Binding var selectedMadhab: Madhab

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prayer Calculation Method")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(Madhab.allCases, id: \.self) { madhab in
                    MadhabButton(
                        madhab: madhab,
                        isSelected: selectedMadhab == madhab,
                        action: {
                            selectedMadhab = madhab
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct MadhabButton: View {
    let madhab: Madhab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(madhab.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)

                Text(madhab.description)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        MadhabSelector(selectedMadhab: .constant(.hanafi))
        Spacer()
    }
    .background(Color(.systemBackground))
}
