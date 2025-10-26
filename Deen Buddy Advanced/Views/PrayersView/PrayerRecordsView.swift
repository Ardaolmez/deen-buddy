//
//  PrayerRecordsView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//
import SwiftUI

struct PrayerRecordsView: View {
    @StateObject var vm = PrayerRecordsViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // Range selector
            SegmentedRange(selected: vm.selectedRange) { vm.setRange($0) }

            // Navigation header with arrows
            NavigationHeader(
                dateRangeText: vm.dateRangeText,
                canGoForward: vm.canGoForward,
                onPrevious: {
                    vm.selectedRange == .week ? vm.goToPreviousWeek() : vm.goToPreviousMonth()
                },
                onNext: {
                    vm.selectedRange == .week ? vm.goToNextWeek() : vm.goToNextMonth()
                }
            )

            // Heatmap
            HeatmapSection(
                days: vm.days,
                range: vm.selectedRange,                     // <-- add range
                colorProvider: { day, prayer in vm.color(for: day, prayer: prayer) },
                statusProvider: { day, prayer in vm.record(for: day, prayer: prayer) }
            )

            // Status summary grid
            SummaryGrid(summary: vm.summary)
        }
        .padding(.bottom, 12)
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .onAppear { vm.reload() }
    }
}

// MARK: - Navigation Header

fileprivate struct NavigationHeader: View {
    let dateRangeText: String
    let canGoForward: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(dateRangeText)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(canGoForward ? .primary : .gray.opacity(0.3))
                    .frame(width: 44, height: 44)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: Heatmap

fileprivate struct HeatmapSection: View {
    let days: [Date]
    let range: RecordsRange
    let colorProvider: (_ day: Date, _ prayer: PrayerName) -> Color
    let statusProvider: (_ day: Date, _ prayer: PrayerName) -> PrayerRecord?

    private let hGap: CGFloat = 6
    private let monthCellSize: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if range == .week {
                weekLayout
            } else {
                monthLayout
            }
        }
    }

    // MARK: - Week Layout (Screen-wide, no scroll)

    @ViewBuilder
    private var weekLayout: some View {
        GeometryReader { geometry in
            let prayerLabelWidth: CGFloat = 90
            let internalPadding: CGFloat = 16
            let totalGaps = hGap * CGFloat(days.count - 1)
            let availableWidth = geometry.size.width - prayerLabelWidth - internalPadding - totalGaps
            let cellSize = availableWidth / CGFloat(max(days.count, 1))

            VStack(alignment: .leading, spacing: 10) {
                heatmapContent(cellSize: cellSize, showMonthHeader: false)
                    .padding(.horizontal, 8)

                Legend().padding(.horizontal, 8)
            }
        }
        .frame(height: 240)  // Fixed height for week layout
    }

    // MARK: - Month Layout (Scrollable)

    @ViewBuilder
    private var monthLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    heatmapContent(cellSize: monthCellSize, showMonthHeader: true)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }

            Legend().padding(.horizontal, 8)
        }
    }

    // MARK: - Shared Heatmap Content

    @ViewBuilder
    private func heatmapContent(cellSize: CGFloat, showMonthHeader: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month header (only for month view)
            if showMonthHeader {
                MonthSpansHeader(days: days, cell: cellSize, hGap: hGap)
            }

            // Grid + Left Labels
            HStack(alignment: .top, spacing: 10) {
                // left labels (prayer names + icons)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(PrayerName.allCases) { p in
                        HStack(spacing: 6) {
                            Image(systemName: p.icon)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text(p.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: cellSize)
                    }
                }
                .padding(.leading, 8)

                // grid
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(PrayerName.allCases) { p in
                        HStack(spacing: hGap) {
                            ForEach(days, id: \.self) { d in
                                let color = colorProvider(d, p)
                                let rec   = statusProvider(d, p)
                                HeatCell(size: cellSize, color: color, record: rec)
                            }
                        }
                    }

                    // Day Ticks
                    DayTicks(days: days, cell: cellSize, hGap: hGap, range: range)
                        .padding(.top, 2)
                }
            }
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.Prayers.statsHeatmapBackground)
            )
        }
    }
}


fileprivate struct MonthSpansHeader: View {
    let days: [Date]
    let cell: CGFloat
    let hGap: CGFloat

    var body: some View {
        let groups = groupByMonth(days: days)
        HStack(alignment: .center, spacing: 0) {
            ForEach(groups, id: \.self.key) { g in
                let width = CGFloat(g.value.count) * cell + CGFloat(max(g.value.count - 1, 0)) * hGap
                Text("\(monthYear(g.key))")
                    .font(.caption.weight(.semibold))
                    .frame(width: width, alignment: .leading)
            }
        }
    }

    private func groupByMonth(days: [Date]) -> [(key: Date, value: [Date])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: days.map { $0.startOfDay }) {
            cal.date(from: cal.dateComponents([.year, .month], from: $0))! // month start as key
        }
        // Sort by month key ascending
        return grouped.sorted { $0.key < $1.key }
    }

    private func monthYear(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: d)
    }
}

fileprivate struct DayTicks: View {
    let days: [Date]
    let cell: CGFloat
    let hGap: CGFloat
    let range: RecordsRange

    var body: some View {
        HStack(spacing: hGap) {
            ForEach(days, id: \.self) { d in
                if shouldShowTick(d) {
                    Text(dayNumber(d))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: cell, alignment: .center)
                } else {
                    Color.clear.frame(width: cell, height: 0)
                }
            }
        }
    }

    private func shouldShowTick(_ d: Date) -> Bool {
        let cal = Calendar.current
        let day = cal.component(.day, from: d)

        switch range {
        case .week:
            return true // show every day
        case .month:
            return day == 1 || day % 2 == 0  // every 2 days + the 1st
        }
    }

    private func dayNumber(_ d: Date) -> String {
        "\(Calendar.current.component(.day, from: d))"
    }
}

// One cell with color and tiny overlay symbol for readability
fileprivate struct HeatCell: View {
    let size: CGFloat
    let color: Color
    let record: PrayerRecord?

    var body: some View {
        ZStack {
               RoundedRectangle(cornerRadius: 5)
                   .fill(color)
                   .frame(width: size, height: size)

               if let record, !symbol(for: record).isEmpty {
                   Image(systemName: symbol(for: record))
                       .font(.system(size: 8, weight: .bold))
                       .foregroundColor(.white.opacity(0.9))
               }
           }
           .accessibilityLabel(Text(accessibilityText(for: record)))
    }

    private func symbol(for r: PrayerRecord) -> String {
        if r.prayerName == .dhuhr, r.day.isFriday, r.statusEnum != .notPrayed {
                return "person.3.fill" // Jumu'ah
            }
        // For all other cells, no overlay icon (return empty)
//            return ""
        switch r.statusEnum {
        case .onTime:    return "checkmark"
        case .late:      return "clock.fill"
        case .notPrayed: return "xmark"
        }
    }

    private func accessibilityText(for r: PrayerRecord?) -> String {
        guard let r else { return "No data" }
        var parts: [String] = []
        parts.append(r.prayerName.title)
        if r.inJamaah { parts.append("in jamaah") }
        parts.append(r.statusEnum.title)
        return parts.joined(separator: ", ")
    }
}

// Month bar across the top (e.g., | Jan | Feb | …)
fileprivate struct MonthBar: View {
    let days: [Date]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { d in
                if isFirstDayOfMonth(d) {
                    Text(monthAbbrev(d))
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.black.opacity(0.05)))
                } else {
                    Spacer().frame(width: 0)
                }
            }
        }
        .frame(height: 16)
    }

    private func isFirstDayOfMonth(_ d: Date) -> Bool {
        Calendar.current.component(.day, from: d) == 1
    }

    private func monthAbbrev(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: d)
    }
}

// Legend explaining colors/symbols
fileprivate struct Legend: View {
    var body: some View {
        HStack(spacing: 14) {
            legendItem(color: AppColors.Prayers.heatmapJamaah, icon: "person.3.fill", text: "Jumu’ah")
            legendItem(color: AppColors.Prayers.heatmapOnTime, icon: "checkmark", text: "On time")
            legendItem(color: AppColors.Prayers.heatmapLate,   icon: "clock.fill", text: "Late")
            legendItem(color: AppColors.Prayers.heatmapMissed, icon: "xmark", text: "Missed")
            legendItem(color: AppColors.Prayers.heatmapEmpty,  icon: "circle", text: "No data")
            Spacer()
        }
    }

    private func legendItem(color: Color, icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                )
            Text(text).font(.caption2).foregroundStyle(.secondary)
        }
    }
}



// MARK: Range selector

fileprivate struct SegmentedRange: View {
    let selected: RecordsRange
    let didSelect: (RecordsRange) -> Void

    // Match the heatmap's adaptive padding
    private let horizontalPadding: CGFloat = 8

    var body: some View {
        HStack(spacing: 10) {
            ForEach(RecordsRange.allCases) { r in
                Button {
                    didSelect(r)
                } label: {
                    Text(r.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(r == selected ? AppColors.Prayers.segmentSelected : AppColors.Prayers.segmentBackground)
                        )
                        .foregroundColor(r == selected ? AppColors.Prayers.segmentTextSelected : .primary)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: Summary cards

fileprivate struct SummaryGrid: View {
    let summary: Summary

    // Match the heatmap's adaptive padding
    private let horizontalPadding: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATUS SUMMARY")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, horizontalPadding)

            // 1) Full-width "On time"
            SummaryCard(
                title: "On time",
                pct: summary.onTimePct,
                count: summary.onTime,
                accent: AppColors.Prayers.heatmapOnTime
            )
            .padding(.horizontal, horizontalPadding)

            // 2) Two-up row: Late + Not prayed
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Late",
                    pct: summary.latePct,
                    count: summary.late,
                    accent: AppColors.Prayers.heatmapLate
                )
                .frame(maxWidth: .infinity)

                SummaryCard(
                    title: "Not prayed",
                    pct: summary.notPrayedPct,
                    count: summary.notPrayed,
                    accent: AppColors.Prayers.heatmapMissed
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}


fileprivate struct SummaryCard: View {
    let title: String
    let pct: Double
    let count: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)

            Text("\(Int(round(pct * 100)))%")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("\(count) times")
                .foregroundColor(.secondary)

            // little bar doodads to echo your mock
            HStack {
                Capsule().fill(accent).frame(height: 6)
                Spacer()
                Circle().fill(accent).frame(width: 6, height: 6)
                Circle().fill(accent).frame(width: 6, height: 6)
                Circle().fill(accent).frame(width: 6, height: 6)
            }
            .padding(.top, 4)

            
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.Prayers.summaryCardBackground)
        )
    }
}
