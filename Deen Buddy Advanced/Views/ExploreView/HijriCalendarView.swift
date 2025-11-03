//
//  HijriCalendarView.swift
//  Deen Buddy Advanced
//
//  Created by Codex CLI on 2025-02-14.
//

import SwiftUI

struct HijriCalendarView: View {
    @ObservedObject var viewModel: HijriDateViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                header

                calendar

                Divider()

                dateDetails

                Spacer()
            }
            .padding(24)
            .navigationTitle(AppStrings.explore.hijriCalendarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.Explore.hijriCardAccent)
                    }
                    .accessibilityLabel(AppStrings.common.close)
                }
            }
        }
        .onAppear {
            selectedDate = Date()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppStrings.explore.hijriCalendarSubtitle)
                .font(.subheadline)
                .foregroundColor(AppColors.Explore.secondaryText)

            Label(viewModel.locationDescription ?? AppStrings.explore.hijriLocationUnavailable,
                  systemImage: "mappin.and.ellipse")
                .font(.footnote)
                .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                .labelStyle(.titleAndIcon)
        }
    }

    private var calendar: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .environment(\.calendar, Calendar(identifier: .islamicUmmAlQura))
        .environment(\.timeZone, viewModel.currentTimeZone)
    }

    private var dateDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.explore.hijriCalendarHijriHeader.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                Text(viewModel.hijriString(for: selectedDate))
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppColors.Explore.hijriCardPrimaryText)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.explore.hijriCalendarGregorianHeader.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                Text(viewModel.gregorianString(for: selectedDate))
                    .font(.body)
                    .foregroundColor(AppColors.Explore.secondaryText)
            }
        }
    }
}

#Preview {
    HijriCalendarView(viewModel: HijriDateViewModel())
}
