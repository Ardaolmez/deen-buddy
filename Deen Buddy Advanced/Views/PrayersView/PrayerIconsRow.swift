// Views/PrayersView/PrayerIconsRow.swift
import SwiftUI

struct PrayerIconsRow: View {
    let entries: [PrayerEntry]
    let currentPrayer: PrayerEntry?
    let isCompleted: (PrayerName) -> Bool
    let canToggle: (PrayerEntry) -> Bool
    let onToggle: (PrayerName) -> Void

    @State private var currentTime = Date()
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            // Header with progress
            // Prayer icons in a row
            HStack(spacing: MinimalDesign.smallSpacing) {
                ForEach(entries) { entry in
                    VStack(spacing: 10) {
                        // Prayer name at top
                        Text(entry.name.title)
                            .font(.system(.caption, weight: .medium))
                            .foregroundStyle(Color.primary)

                        // Prayer icon with enhanced visual feedback
                        ZStack {
                            // Background circle with subtle shadow
                            Circle()
                                .fill(Color(.systemGray6).opacity(0.5))
                                .frame(width: 60, height: 60)
                                .shadow(color: timeOfDayColor(for: entry.name).opacity(0.2), radius: 4, x: 0, y: 2)

                            // Background ring (gray outline) - always visible
                            Circle()
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 68, height: 68)

                            // Progress ring - fills based on prayer state
                            let progress = progressForPrayer(entry)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(timeOfDayColor(for: entry.name), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 68, height: 68)
                                .rotationEffect(.degrees(-90))

                            // Prayer icon
                            Image(systemName: entry.name.icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(timeOfDayColor(for: entry.name))

                        }
                        .opacity(canToggle(entry) ? 1.0 : 0.5)
                        .scaleEffect(canToggle(entry) ? 1.0 : 0.95)

                        // Prayer time below icon
                        Text(timeString(entry.time))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if canToggle(entry) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                onToggle(entry.name)
                            }
                        }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private func backgroundColorFor(_ entry: PrayerEntry) -> Color {
        if isCompleted(entry.name) {
            return AppColors.Prayers.subtleGreen
        } else if entry.id == currentPrayer?.id {
            return AppColors.Prayers.subtleBlue
        } else {
            return AppColors.Prayers.subtleGray
        }
    }

    private func iconColorFor(_ entry: PrayerEntry) -> Color {
        if isCompleted(entry.name) {
            return AppColors.Prayers.prayerGreen
        } else if entry.id == currentPrayer?.id {
            return AppColors.Prayers.prayerBlue
        } else {
            return AppColors.Common.primary
        }
    }

    private func shadowColorFor(_ entry: PrayerEntry) -> Color {
        if isCompleted(entry.name) {
            return AppColors.Prayers.greenShadow
        } else if entry.id == currentPrayer?.id {
            return AppColors.Prayers.blueShadow
        } else {
            return AppColors.Prayers.lightShadow
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Time-of-day Color
    private func timeOfDayColor(for prayer: PrayerName) -> Color {
        switch prayer {
        case .fajr:
            return AppColors.Prayers.fajrColor
        case .dhuhr:
            return AppColors.Prayers.dhuhrColor
        case .asr:
            return AppColors.Prayers.asrColor
        case .maghrib:
            return AppColors.Prayers.maghribColor
        case .isha:
            return AppColors.Prayers.ishaColor
        }
    }

    // MARK: - Progress Calculation
    private func progressForPrayer(_ entry: PrayerEntry) -> CGFloat {
        let calendar = Calendar.current
        let entryDay = calendar.startOfDay(for: entry.time)
        let currentDay = calendar.startOfDay(for: currentTime)

        // If prayer is from a previous day, reset to 0 (new day)
        if entryDay < currentDay {
            return 0.0
        }

        // If prayer time has passed (same day), it's completed
        if entry.time < currentTime {
            return 1.0
        }

        // Prayer is in the future
        // Check if this is the next upcoming prayer
        let futurePrayers = entries.filter { $0.time > currentTime }.sorted { $0.time < $1.time }
        guard let nextPrayer = futurePrayers.first else {
            return 0.0
        }

        // If this IS the next prayer, show progress toward it
        if entry.id == nextPrayer.id {
            // Find the previous prayer time (or start of day if this is first prayer)
            let previousTime: Date
            if let currentPrayerEntry = currentPrayer {
                previousTime = currentPrayerEntry.time
            } else {
                // No current prayer - use start of day or find previous prayer
                let pastPrayers = entries.filter { $0.time < currentTime }.sorted { $0.time < $1.time }
                if let lastPrayer = pastPrayers.last {
                    previousTime = lastPrayer.time
                } else {
                    // First prayer of the day - use midnight
                    previousTime = calendar.startOfDay(for: currentTime)
                }
            }

            let totalDuration = entry.time.timeIntervalSince(previousTime)
            let elapsed = currentTime.timeIntervalSince(previousTime)
            let progress = min(max(elapsed / totalDuration, 0), 1.0)
            return progress
        }

        // Not the next prayer - empty ring
        return 0.0
    }
}
