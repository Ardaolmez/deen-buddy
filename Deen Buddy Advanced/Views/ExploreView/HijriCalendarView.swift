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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    summaryCard
                    calendarCard
                    detailCard
                }
                .padding(20)
            }
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

    private var summaryCard: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.Explore.accentLight)
                    .frame(width: 48, height: 48)

                Image(systemName: "moonphase.first.quarter.waxing")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.Explore.hijriCardAccent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.hijriString(for: selectedDate))
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(AppColors.Explore.primaryText)
                    .lineLimit(2)

                Text(viewModel.gregorianString(for: selectedDate))
                    .font(.subheadline)
                    .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.Explore.subtleAccent,
                            AppColors.Explore.hijriCardBackground.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppColors.Explore.hijriCardBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.Explore.cardShadow.opacity(0.45), radius: 14, x: 0, y: 6)
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.explore.hijriCalendarSubtitle)
                .font(.callout.weight(.semibold))
                .foregroundColor(AppColors.Explore.hijriCardPrimaryText)

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .environment(\.calendar, Calendar(identifier: .islamicUmmAlQura))
            .environment(\.timeZone, viewModel.currentTimeZone)
            .tint(AppColors.Explore.hijriCardAccent)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.Explore.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Explore.subtleBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.Explore.cardShadow.opacity(0.5), radius: 12, x: 0, y: 5)
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                detailColumn(
                    title: AppStrings.explore.hijriCalendarHijriHeader,
                    value: viewModel.hijriString(for: selectedDate)
                )

                detailColumn(
                    title: AppStrings.explore.hijriCalendarGregorianHeader,
                    value: viewModel.gregorianString(for: selectedDate)
                )
            }

            Text(AppStrings.explore.hijriCalendarHint)
                .font(.footnote)
                .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.Explore.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Explore.subtleBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.Explore.cardShadow.opacity(0.45), radius: 10, x: 0, y: 4)
    }

    private func detailColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundColor(AppColors.Explore.hijriCardSecondaryText.opacity(0.9))

            Text(value)
                .font(.body)
                .foregroundColor(AppColors.Explore.hijriCardPrimaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HijriCalendarView(viewModel: HijriDateViewModel())
}
