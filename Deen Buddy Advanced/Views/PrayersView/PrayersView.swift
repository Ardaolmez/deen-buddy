// Views/Prayers/PrayersView.swift
import SwiftUI

struct PrayersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PrayersViewModel()
    @State private var openRecords = false   // ⬅️ state to push records

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Header card: city, current/next, countdown
                    if let h = vm.header {
                        HeaderCard(
                            cityLine: vm.cityLine,
                            currentLine: vm.isBetweenSunriseAndDhuhr
                                ? String(format: AppStrings.prayers.nextDhuhrFormat, AppStrings.prayers.next, AppStrings.prayers.dhuhr, time(h.dhuhr))
                                : nowLine(current: vm.currentPrayer),
                            countdown: vm.countdownText,
                            nextLine: nextLine(next: vm.nextPrayer, h: h),
                            sunrise: h.sunrise,
                            sunset: h.sunset,
                            zawalStart: h.zawalStart,
                            zawalEnd: h.zawalEnd
                        )
                        .padding(.horizontal)
                    }

                    // “Did you pray?” prompt for current prayer (if any)
                    if let current = vm.currentPrayer {
                        CompletedPrompt(
                            prayer: current.name.title,
                            completed: vm.isCompleted(current.name),
                            onToggle: { vm.toggleCompleted(current.name) }
                        )
                        .padding(.horizontal)
                    }

                    // List
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppStrings.prayers.todaysPrayers)
                            .font(.system(.title3, design: .serif).weight(.semibold))
                            .padding(.horizontal)

                        ForEach(vm.entries) { entry in
                            PrayerRow(entry: entry,
                                      isCurrent: entry.id == vm.currentPrayer?.id,
                                      isCompleted: vm.isCompleted(entry.name),
                                      onToggle: { vm.toggleCompleted(entry.name) })
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitle(AppStrings.prayers.navigationTitle, displayMode: .inline)
            .toolbar {
                // ⬅️ Trailing "History / Stats" button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PrayerRecordsView(), isActive: $openRecords) {
                        Label(AppStrings.prayers.history, systemImage: "chart.bar.xaxis")
                            .labelStyle(.iconOnly)   // icon-only; remove if you want text
                            .font(.system(size: 18, weight: .semibold))
                    }
                }}
        }
    }

    private func time(_ d: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: d)
    }

    private func nowLine(current: PrayerEntry?) -> String {
        if let c = current {
            return String(format: AppStrings.prayers.nowPrayerFormat, AppStrings.prayers.now, c.name.title, time(c.time))
        }
        return AppStrings.prayers.beforeFajr
    }

    private func nextLine(next: PrayerEntry?, h: DayTimes) -> String {
        if let n = next {
            // if next < now it's tomorrow's fajr, but ViewModel already handles countdown across days
            let isTomorrowFajr = Calendar.current.isDate(n.time, inSameDayAs: Date()) == false && n.name == .fajr
            return isTomorrowFajr
                ? String(format: AppStrings.prayers.nextPrayerTomorrow, n.name.title)
                : String(format: AppStrings.prayers.nextPrayerAt, n.name.title, time(n.time))
        }
        return String(format: AppStrings.prayers.nextPrayerTomorrow, "Fajr")
    }
}



private struct HeaderCard: View {
    let cityLine: String
    let currentLine: String
    let countdown: String
    let nextLine: String

    let sunrise: Date
    let sunset: Date
    let zawalStart: Date
    let zawalEnd: Date

    var body: some View {
        VStack(spacing: 14) {
            Text(cityLine)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(currentLine)
                .font(.system(.title3, design: .serif).weight(.semibold))

            HStack(spacing: 8) {
                Image(systemName: "clock")
                Text(countdown)
                    .font(.system(.headline, design: .monospaced))
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Capsule().fill(AppColors.Prayers.countdownBackground))
            .foregroundStyle(AppColors.Prayers.countdownText)

            Text(nextLine)
                .font(.callout)
                .foregroundStyle(.secondary)

            // Sunrise / Sunset / Zawal line (Islam360-style)
            HStack(spacing: 16) {
                SunStat(icon: "sunrise.fill", title: AppStrings.prayers.sunrise, time: sunrise)
                Divider().frame(height: 22)
                SunStat(icon: "sun.max.fill", title: AppStrings.prayers.zawal, range: zawalStart...zawalEnd)
                Divider().frame(height: 22)
                SunStat(icon: "sunset.fill", title: AppStrings.prayers.sunset, time: sunset)
            }
            .padding(.top, 6)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.Prayers.headerBackground)
                .shadow(color: AppColors.Prayers.headerShadow, radius: 12, x: 0, y: 6)
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
            Image(systemName: icon).font(.system(size: 14, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                if let t = time {
                    Text(timeString(t)).font(.footnote.weight(.semibold))
                } else if let r = range {
                    Text("\(timeString(r.lowerBound)) – \(timeString(r.upperBound))")
                        .font(.footnote.weight(.semibold))
                }
            }
        }
    }
    private func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: d)
    }
}

private struct PrayerRow: View {
    let entry: PrayerEntry
    let isCurrent: Bool
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name.title)
                    .font(.system(.headline, design: .serif))
                if isCurrent {
                    Text(AppStrings.prayers.current).font(.caption2).foregroundStyle(AppColors.Prayers.currentPrayerAccent)
                }
            }
            Spacer()
            Text(timeString(entry.time))
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isCompleted ? AppColors.Prayers.completedCheckmark : AppColors.Prayers.uncompletedCheckmark)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isCurrent ? AppColors.Prayers.rowCurrentBackground : AppColors.Prayers.rowNormalBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isCurrent ? AppColors.Prayers.rowCurrentBorder : AppColors.Prayers.rowNormalBorder,
                        lineWidth: isCurrent ? 1.2 : 0.5)
        )
        .padding(.horizontal)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

private struct CompletedPrompt: View {
    let prayer: String
    let completed: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: completed ? "checkmark.circle.fill" : "questionmark.circle")
                .foregroundStyle(completed ? AppColors.Prayers.promptCompleted : AppColors.Prayers.promptIncomplete)
                .font(.system(size: 20, weight: .semibold))
            VStack(alignment: .leading, spacing: 4) {
                Text(completed ? AppStrings.prayers.greatJob : String(format: AppStrings.prayers.didYouPray, prayer))
                    .font(.system(.headline, design: .serif))
                Text(completed ? AppStrings.prayers.markedCompleted : AppStrings.prayers.markCompleted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggle) {
                Text(completed ? AppStrings.prayers.undo : AppStrings.prayers.yes)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(completed ? AppColors.Prayers.promptCompletedBackground : AppColors.Prayers.promptIncompleteBackground))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.Prayers.cardBackground)
        )
    }
}
