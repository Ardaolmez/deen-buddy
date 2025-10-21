// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {

                    // MARK: Header
                    if let h = vm.header {
                        HeaderCard(
                            cityLine: vm.cityLine,
                            line1: vm.isBetweenSunriseAndDhuhr
                                ? String(format: AppStrings.prayers.nextDhuhrCompact,
                                         AppStrings.prayers.dhuhr,
                                         time(h.dhuhr))
                                : nowLine(current: vm.currentPrayer),
                            countdown: vm.countdownText,
                            line2: nextLine(next: vm.nextPrayer, h: h),
                            sunrise: h.sunrise, sunset: h.sunset,
                            zawalStart: h.zawalStart, zawalEnd: h.zawalEnd
                        )
                        .padding(.horizontal, 14)
                    }

                    // MARK: Weekly streak
                    StreakCard(weekStatus: vm.streakWeekStatus)
                        .padding(.horizontal, 14)

                    // MARK: Quick prompt for the current prayer
                    if let current = vm.currentPrayer {
                        CompletedPrompt(
                            prayer: current.name.title,
                            completed: vm.isCompleted(current.name),
                            onToggle: {
                                vm.toggleCompleted(current.name)
                                vm.recomputeWeekStreak()
                            }
                        )
                        .padding(.horizontal, 14)
                    }

                    // MARK: Today’s prayers
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppStrings.prayers.todaysPrayers)
                            .font(.system(.headline, design: .serif))
                            .padding(.horizontal, 14)

                        ForEach(vm.entries) { entry in
                            PrayerRow(
                                entry: entry,
                                isCurrent: entry.id == vm.currentPrayer?.id,
                                isCompleted: vm.isCompleted(entry.name),
                                canToggle: vm.canMark(entry),
                                onToggle: {
                                    vm.toggleCompleted(entry.name)
                                    vm.recomputeWeekStreak()
                                }
                            )
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle(AppStrings.prayers.navigationTitle, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PrayerRecordsView(), isActive: $openRecords) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
        }
        .onAppear { vm.recomputeWeekStreak() }
    }

    // MARK: Helpers
    private func time(_ d: Date) -> String { let f = DateFormatter(); f.timeStyle = .short; return f.string(from: d) }

    private func nowLine(current: PrayerEntry?) -> String {
        if let c = current {
            return String(format: AppStrings.prayers.nowPrayerCompact, c.name.title, time(c.time))
        }
        return AppStrings.prayers.beforeFajr
    }

    private func nextLine(next: PrayerEntry?, h: DayTimes) -> String {
        if let n = next {
            let isTomorrowFajr = Calendar.current.isDate(n.time, inSameDayAs: Date()) == false && n.name == .fajr
            return isTomorrowFajr
                ? String(format: AppStrings.prayers.nextPrayerTomorrow, n.name.title)
                : String(format: AppStrings.prayers.nextPrayerAt, n.name.title, time(n.time))
        }
        return String(format: AppStrings.prayers.nextPrayerTomorrow, "Fajr")
    }
}

// MARK: - Header (compact)
private struct HeaderCard: View {
    let cityLine: String
    let line1: String
    let countdown: String
    let line2: String

    let sunrise: Date
    let sunset: Date
    let zawalStart: Date
    let zawalEnd: Date

    var body: some View {
        VStack(spacing: 10) {
            Text(cityLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(line1)
                .font(.system(.title3, design: .serif).weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 6) {
                Image(systemName: "clock")
                Text(countdown)
                    .font(.system(.headline, design: .monospaced))
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(AppColors.Prayers.countdownBackground))
            .foregroundStyle(AppColors.Prayers.countdownText)

            Text(line2)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Sunrise / Zawal / Sunset in one tight row
            HStack(spacing: 14) {
                SunStat(icon: "sunrise.fill", title: AppStrings.prayers.sunrise, time: sunrise)
                Divider().frame(height: 20)
                SunStat(icon: "sun.max.fill", title: AppStrings.prayers.zawal, range: zawalStart...zawalEnd)
                Divider().frame(height: 20)
                SunStat(icon: "sunset.fill", title: AppStrings.prayers.sunset, time: sunset)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.Prayers.headerBackground)
                .shadow(color: AppColors.Prayers.headerShadow, radius: 10, x: 0, y: 5)
        )
    }
}

private struct SunStat: View {
    let icon: String
    let title: String
    var time: Date? = nil
    var range: ClosedRange<Date>? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 13, weight: .semibold))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption2).foregroundStyle(.secondary)
                if let t = time {
                    Text(short(t)).font(.footnote.weight(.semibold))
                } else if let r = range {
                    Text("\(short(r.lowerBound))–\(short(r.upperBound))").font(.footnote.weight(.semibold))
                }
            }
        }
    }
    private func short(_ d: Date) -> String { let f = DateFormatter(); f.timeStyle = .short; return f.string(from: d) }
}

private struct StreakCard: View {
    /// Monday-first, 7 items; true = day complete
    let weekStatus: [Bool]

    private let labels = ["M","T","W","T","F","S","S"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title row
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(AppColors.Prayers.countdownText)
                Text(AppStrings.prayers.prayerStreakTitle)
                    .font(.system(.headline, design: .serif))
                Spacer()
            }

            // Weekday labels — full width via 7 flexible columns
            LazyVGrid(columns: columns, alignment: .center, spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    Text(labels[i])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity) // each column fills its slot
                }
            }

            // Squares row — full width via same 7 columns
            LazyVGrid(columns: columns, alignment: .center, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    let done = (i < weekStatus.count) ? weekStatus[i] : false
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(done ? AppColors.Prayers.completedCheckmark
                                   : Color(.systemGray5))
                        .frame(height: 28)                 // width auto from column
                        .overlay(
                            Group {
                                if done {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                        )
                        .accessibilityLabel(done ? "Completed" : "Not completed")
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)   // ⬅️ card fills width
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.Prayers.cardBackground)
        )
    }
}



// MARK: - Row & Prompt (dense)
private struct PrayerRow: View {
    let entry: PrayerEntry
    let isCurrent: Bool
    let isCompleted: Bool
    let canToggle: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(entry.name.title)
                        .font(.system(.body, design: .serif).weight(.semibold))
                    if isCurrent {
                        Text(AppStrings.prayers.current)
                            .font(.caption2)
                            .foregroundStyle(AppColors.Prayers.currentPrayerAccent)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.Prayers.rowCurrentBackground))
                    }
                }

                HStack(spacing: 6) {
                    Text(timeString(entry.time))
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.secondary)
                    if !canToggle {
                        Text(AppStrings.prayers.availableLater)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 8)

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isCompleted ? AppColors.Prayers.completedCheckmark
                                                 : AppColors.Prayers.uncompletedCheckmark)
            }
            .disabled(!canToggle)
            .opacity(canToggle ? 1.0 : 0.35)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent
                      ? AppColors.Prayers.rowCurrentBackground.opacity(0.25)
                      : AppColors.Prayers.rowNormalBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isCurrent
                        ? AppColors.Prayers.rowCurrentBorder
                        : AppColors.Prayers.rowNormalBorder,
                        lineWidth: isCurrent ? 1 : 0.5)
        )
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }
}

private struct CompletedPrompt: View {
    let prayer: String
    let completed: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: completed ? "checkmark.circle.fill" : "questionmark.circle")
                .foregroundStyle(completed ? AppColors.Prayers.promptCompleted : AppColors.Prayers.promptIncomplete)
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(completed ? AppStrings.prayers.greatJob
                               : String(format: AppStrings.prayers.didYouPray, prayer))
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                Text(completed ? AppStrings.prayers.markedCompleted
                               : AppStrings.prayers.markCompleted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button(action: onToggle) {
                Text(completed ? AppStrings.prayers.undo : AppStrings.prayers.yes)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(completed
                                  ? AppColors.Prayers.promptCompletedBackground
                                  : AppColors.Prayers.promptIncompleteBackground)
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.Prayers.cardBackground)
        )
    }
}
