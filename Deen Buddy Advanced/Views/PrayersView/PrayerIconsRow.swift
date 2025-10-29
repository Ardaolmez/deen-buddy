// Views/PrayersView/PrayerIconsRow.swift
import SwiftUI

struct PrayerIconsRow: View {
    let entries: [PrayerEntry]
    let currentPrayer: PrayerEntry?
    let nextPrayer: PrayerEntry?
    let countdown: String
    let isCompleted: (PrayerName) -> Bool
    let canToggle: (PrayerEntry) -> Bool
    let onToggle: (PrayerName) -> Void

    @State private var currentTime = Date()
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: MinimalDesign.smallSpacing) {
                ForEach(entries) { entry in
                    VStack(spacing: 10) {
                        
                        // Prayer name at top
                        Text(entry.name.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.primary)

                        // All prayers use square design
                        ZStack {
                            // Background square
                            RoundedRectangle(cornerRadius: 12)
                                .fill(squareColorFor(entry))
                                .frame(width: 68, height: 68)
                                .shadow(color: shadowColorFor(entry), radius: 4, x: 0, y: 2)

                            // Border only for next prayer
                            if isNextPrayer(entry) {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.Prayers.prayerBlue, lineWidth: 4)
                                    .frame(width: 68, height: 68)
                            }

                            VStack(spacing: 2) {
                                // Prayer icon
                                Image(systemName: entry.name.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(iconColorFor(entry))

                                // Prayer time
                                Text(timeString(entry.time))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(timeColorFor(entry))
                                    .monospacedDigit()
                            }
                        }
                        .opacity(canToggle(entry) ? 1.0 : 1)
                        .scaleEffect(canToggle(entry) ? 1.0 : 1)

                        // Countdown only for next prayer - fixed height to prevent jump
                        Group {
                            if isNextPrayer(entry) && !countdown.isEmpty && countdown != "—" && countdown != "--:--:--" {
                                Text(countdown)
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(Color.primary)
                                    .monospacedDigit()
                            } else {
                                Text(" ")
                                    .font(.caption2.weight(.medium))
                            }
                        }
                        .frame(height: 16)
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

    private func isNextPrayer(_ entry: PrayerEntry) -> Bool {
        return entry.id == nextPrayer?.id
    }

    // Prayer states for color coding
    private enum PrayerState {
        case completed, current, next, missed, future
    }

    // Helper function to determine prayer state
    private func prayerState(_ entry: PrayerEntry) -> PrayerState {
        // Ignore completion status for now
        if entry.id == currentPrayer?.id {
            return .current
        } else if isNextPrayer(entry) {
            return .next
        } else {
            return .future
        }
    }

    // Square background colors based on prayer state
    private func squareColorFor(_ entry: PrayerEntry) -> Color {
        // All prayers use same creamy papyrus background
        return Color(red: 0.99, green: 0.98, blue: 0.94)
    }

    // Icon colors based on prayer state
    private func iconColorFor(_ entry: PrayerEntry) -> Color {
        // Use chat view green color for light mode
        return Color(red: 0.29, green: 0.55, blue: 0.42)
    }

    // Time text colors based on prayer state
    private func timeColorFor(_ entry: PrayerEntry) -> Color {
        // Use chat view green color for light mode
        return Color(red: 0.29, green: 0.55, blue: 0.42)
    }

    // Shadow colors based on prayer state
    private func shadowColorFor(_ entry: PrayerEntry) -> Color {
        // Subtle shadow for all prayers without opacity
        return Color(red: 0.29, green: 0.55, blue: 0.42)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func timeOfDayColor(for prayer: PrayerName) -> Color {
        switch prayer {
        case .fajr: return AppColors.Prayers.fajrColor
        case .dhuhr: return AppColors.Prayers.dhuhrColor
        case .asr: return AppColors.Prayers.asrColor
        case .maghrib: return AppColors.Prayers.maghribColor
        case .isha: return AppColors.Prayers.ishaColor
        }
    }

    private func progressForPrayer(_ entry: PrayerEntry) -> CGFloat {
        let calendar = Calendar.current
        let entryDay = calendar.startOfDay(for: entry.time)
        let currentDay = calendar.startOfDay(for: currentTime)

        if entryDay < currentDay { return 0.0 }
        if entry.time < currentTime { return 1.0 }

        let futurePrayers = entries.filter { $0.time > currentTime }.sorted { $0.time < $1.time }
        guard let nextPrayer = futurePrayers.first else { return 0.0 }

        if entry.id == nextPrayer.id {
            let previousTime: Date =
                currentPrayer?.time ??
                entries.filter { $0.time < currentTime }.sorted { $0.time < $1.time }.last?.time ??
                calendar.startOfDay(for: currentTime)

            let total = entry.time.timeIntervalSince(previousTime)
            let elapsed = currentTime.timeIntervalSince(previousTime)
            return min(max(elapsed / total, 0), 1.0)
        }

        return 0.0
    }
}

