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
    @State private var selectedSpecialDate: HijriSpecialDate?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    summaryCard
                    specialDatesCard
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

                Image(systemName: "moon.stars.fill")
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

    private var specialDatesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.explore.hijriCalendarSpecialDatesTitle)
                .font(.callout.weight(.semibold))
                .foregroundColor(AppColors.Explore.hijriCardPrimaryText)

            Menu {
                if selectedSpecialDate != nil {
                    Button(AppStrings.explore.hijriCalendarSpecialDatesReset, role: .destructive) {
                        withAnimation {
                            selectedSpecialDate = nil
                            selectedDate = Date()
                        }
                    }
                }

                ForEach(HijriSpecialDate.defaultDates) { specialDate in
                    Button(specialDate.title) {
                        jump(to: specialDate)
                    }
                }
            } label: {
                HStack {
                    Text(selectedSpecialDate?.title ?? AppStrings.explore.hijriCalendarSpecialDatesPlaceholder)
                        .font(.subheadline)
                        .foregroundColor(AppColors.Explore.hijriCardPrimaryText.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.Explore.hijriCardSecondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppColors.Explore.cardBackground)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(AppColors.Explore.subtleBorder, lineWidth: 1)
                )
                .shadow(color: AppColors.Explore.cardShadow.opacity(0.35), radius: 8, x: 0, y: 3)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.Explore.hijriCardBackground.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.Explore.hijriCardBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.Explore.cardShadow.opacity(0.45), radius: 10, x: 0, y: 4)
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

    private func jump(to specialDate: HijriSpecialDate) {
        guard let target = specialDate.date(in: viewModel.currentTimeZone) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedSpecialDate = specialDate
            selectedDate = target
        }
    }
}

private struct HijriSpecialDate: Identifiable, Hashable {
    let id: String
    let title: String
    let month: Int
    let day: Int

    init(title: String, month: Int, day: Int) {
        self.id = "\(month)-\(day)"
        self.title = title
        self.month = month
        self.day = day
    }

    func date(in timeZone: TimeZone) -> Date? {
        var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        hijriCalendar.timeZone = timeZone

        guard let currentHijriYear = hijriCalendar.dateComponents([.year], from: Date()).year else {
            return nil
        }

        var components = DateComponents()
        components.calendar = hijriCalendar
        components.timeZone = timeZone
        components.year = currentHijriYear
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0

        return hijriCalendar.date(from: components)
    }

    static let defaultDates: [HijriSpecialDate] = [
        HijriSpecialDate(title: "1 Muharram – Islamic New Year", month: 1, day: 1),
        HijriSpecialDate(title: "10 Muharram – Ashura", month: 1, day: 10),
        HijriSpecialDate(title: "12 Rabi al-Awwal – Mawlid", month: 3, day: 12),
        HijriSpecialDate(title: "27 Rajab – Shab e Miraj", month: 7, day: 27),
        HijriSpecialDate(title: "15 Sha'ban – Shab e Barat", month: 8, day: 15),
        HijriSpecialDate(title: "1 Ramadan – First Fasting Day", month: 9, day: 1),
        HijriSpecialDate(title: "17 Ramadan – Battle of Badr", month: 9, day: 17),
        HijriSpecialDate(title: "27 Ramadan – Laylat al-Qadr", month: 9, day: 27),
        HijriSpecialDate(title: "1 Shawwal – Eid al-Fitr", month: 10, day: 1),
        HijriSpecialDate(title: "9 Dhu al-Hijjah – Day of Arafat", month: 12, day: 9),
        HijriSpecialDate(title: "10 Dhu al-Hijjah – Eid al-Adha", month: 12, day: 10)
    ]
}

#Preview {
    HijriCalendarView(viewModel: HijriDateViewModel())
}
