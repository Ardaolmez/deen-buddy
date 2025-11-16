//
//  SurahJuzToggle.swift
//  Deen Buddy Advanced
//
//  Toggle component for switching between Surah and Juz views
//

import SwiftUI

enum NavigationMode: String, CaseIterable {
    case surah
    case juz

    var displayName: String {
        switch self {
        case .surah: return AppStrings.quran.surahBysurah
        case .juz: return AppStrings.quran.juzByJuz
        }
    }
}

struct SurahJuzToggle: View {
    @Binding var selectedMode: NavigationMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedMode == mode ? AppColors.VerseByVerse.accentGreen : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SurahJuzToggle(selectedMode: .constant(.surah))
        SurahJuzToggle(selectedMode: .constant(.juz))
    }
    .padding()
}
