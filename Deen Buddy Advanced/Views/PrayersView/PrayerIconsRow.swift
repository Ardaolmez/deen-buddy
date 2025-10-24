// Views/PrayersView/PrayerIconsRow.swift
import SwiftUI

struct PrayerIconsRow: View {
    let entries: [PrayerEntry]
    let currentPrayer: PrayerEntry?
    let isCompleted: (PrayerName) -> Bool
    let canToggle: (PrayerEntry) -> Bool
    let onToggle: (PrayerName) -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header with progress
            // Prayer icons in a row
            HStack(spacing: MinimalDesign.smallSpacing) {
                ForEach(entries) { entry in
                    VStack(spacing: 10) {
                        // Prayer icon with enhanced visual feedback
                        ZStack {
                            // Background circle with subtle shadow
                            Circle()
                                .fill(backgroundColorFor(entry))
                                .frame(width: 60, height: 60)
                                .shadow(color: shadowColorFor(entry), radius: 4, x: 0, y: 2)

                            // Prayer icon
                            Image(systemName: entry.name.icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(iconColorFor(entry))

                            // Completion indicator
                            if isCompleted(entry.name) {
                                Circle()
                                    .stroke(AppColors.Prayers.prayerGreen, lineWidth: 2.5)
                                    .frame(width: 60, height: 60)

                                // Checkmark overlay
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.Common.white)
                                    .background(
                                        Circle()
                                            .fill(AppColors.Prayers.prayerGreen)
                                            .frame(width: 18, height: 18)
                                    )
                                    .offset(x: 18, y: -18)
                            }

                            // Current prayer pulse effect
                            if entry.id == currentPrayer?.id && !isCompleted(entry.name) {
                                Circle()
                                    .stroke(AppColors.Prayers.prayerBlue.opacity(0.3), lineWidth: 2)
                                    .frame(width: 70, height: 70)
                                    .scaleEffect(1.1)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: true)
                            }
                        }

                        // Prayer details
                        VStack(spacing: 2) {
                            Text(entry.name.title)
                                .font(.system(.caption, weight: .medium))
                                .foregroundStyle(AppColors.Common.primary)

                            Text(timeString(entry.time))
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(AppColors.Common.secondary)
                        }
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
                    .opacity(canToggle(entry) ? 1.0 : 0.5)
                    .scaleEffect(canToggle(entry) ? 1.0 : 0.95)
                }
            }
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
}
