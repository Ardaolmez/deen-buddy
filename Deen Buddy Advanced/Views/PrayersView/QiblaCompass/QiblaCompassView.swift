//
//  QiblaCompassView.swift
//  Deen Buddy Advanced
//
//  Qibla compass component for PrayersView
//

import SwiftUI

struct QiblaCompassView: View {
    @StateObject private var vm = QiblaCompassViewModel()
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Tap to expand/collapse
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.Prayers.prayerGreen)

                    Text("Qibla Direction")
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(AppColors.Common.primary)

                    Spacer()

                    if vm.locationAvailable {
                        Text(vm.qiblaDirectionText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(AppColors.Common.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.Prayers.subtleGreen)
                            .cornerRadius(6)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColors.Common.secondary)
                }
                .padding(.horizontal, MinimalDesign.mediumSpacing)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            // Expanded compass view
            if isExpanded {
                VStack(spacing: MinimalDesign.mediumSpacing) {
                    Divider()

                    if vm.locationAvailable {
                        // Compass visualization
                        CompassRoseView(
                            relativeQiblaAngle: vm.relativeQiblaAngle,
                            isPointingToQibla: vm.isPointingTowardQibla
                        )
                        .frame(height: 200)
                        .padding(.vertical, MinimalDesign.smallSpacing)

                        // Info row
                        HStack(spacing: MinimalDesign.largeSpacing) {
                            // Bearing
                            InfoPill(
                                icon: "location.north.fill",
                                label: "Bearing",
                                value: vm.qiblaBearingText,
                                color: AppColors.Prayers.prayerBlue
                            )

                            // Distance
                            InfoPill(
                                icon: "ruler",
                                label: "Distance",
                                value: vm.distanceText,
                                color: AppColors.Prayers.prayerGreen
                            )
                        }
                        .padding(.horizontal, MinimalDesign.mediumSpacing)

                        // Calibration warning
                        if vm.isCalibrationNeeded {
                            CalibrationWarningView()
                                .padding(.horizontal, MinimalDesign.mediumSpacing)
                        }

                        // Accuracy indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(vm.compassAccuracy > 0.5 ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerOrange)
                                .frame(width: 6, height: 6)

                            Text(vm.accuracyText)
                                .font(.caption)
                                .foregroundStyle(AppColors.Common.secondary)
                        }
                        .padding(.bottom, MinimalDesign.smallSpacing)
                    } else {
                        // Loading state
                        VStack(spacing: MinimalDesign.smallSpacing) {
                            ProgressView()
                            Text("Getting location...")
                                .font(.caption)
                                .foregroundStyle(AppColors.Common.secondary)
                        }
                        .frame(height: 100)
                    }
                }
                .padding(.bottom, MinimalDesign.mediumSpacing)
            }
        }
        .background(AppColors.Common.systemGray6)
        .cornerRadius(MinimalDesign.largeCornerRadius)
        .onAppear {
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
    }
}

// MARK: - Compass Rose View

struct CompassRoseView: View {
    let relativeQiblaAngle: Double
    let isPointingToQibla: Bool

    // Track continuous angle to prevent 360° wrapping jumps
    @State private var continuousAngle: Double = 0.0
    @State private var lastAngle: Double = 0.0

    var body: some View {
        ZStack {
            // Outer compass ring
            compassRing

            // Qibla direction indicator
            qiblaIndicator

            // Center dot
            centerDot
        }
        .onChange(of: relativeQiblaAngle) { newValue in
            updateContinuousAngle(newValue)
        }
        .onAppear {
            continuousAngle = relativeQiblaAngle
            lastAngle = relativeQiblaAngle
        }
    }

    // MARK: - Subviews

    private var compassRing: some View {
        ZStack {
            Circle()
                .strokeBorder(AppColors.Common.systemGray5, lineWidth: 2)
                .background(Circle().fill(AppColors.Common.white))

            cardinalDirections
            degreeMarkers
        }
        .frame(width: 160, height: 160)
    }

    private var cardinalDirections: some View {
        ForEach(["N", "E", "S", "W"], id: \.self) { direction in
            Text(direction)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(directionColor(direction))
                .offset(y: directionOffsetY(direction))
                .offset(x: directionOffsetX(direction))
        }
    }

    private var degreeMarkers: some View {
        ForEach(0..<36) { i in
            Rectangle()
                .fill(i % 3 == 0 ? AppColors.Common.secondary : AppColors.Common.systemGray5)
                .frame(width: i % 3 == 0 ? 2 : 1, height: i % 3 == 0 ? 10 : 6)
                .offset(y: -70)
                .rotationEffect(.degrees(Double(i) * 10))
        }
    }

    private var qiblaIndicator: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isPointingToQibla ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                    .frame(width: 44, height: 44)
                    .shadow(color: isPointingToQibla ? AppColors.Prayers.greenShadow : AppColors.Prayers.blueShadow, radius: 8)

                Image(systemName: "mosque")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.Common.white)
            }

            if isPointingToQibla {
                Text("Qibla")
                    .font(.system(.caption2, weight: .semibold))
                    .foregroundStyle(AppColors.Prayers.prayerGreen)
            }
        }
        .offset(y: -60)
        .rotationEffect(.degrees(continuousAngle))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: continuousAngle)
    }

    private var centerDot: some View {
        Circle()
            .fill(AppColors.Common.systemGray5)
            .frame(width: 8, height: 8)
    }

    // MARK: - Helper Methods

    private func directionColor(_ direction: String) -> Color {
        direction == "N" ? AppColors.Prayers.prayerGreen : AppColors.Common.secondary
    }

    private func directionOffsetY(_ direction: String) -> CGFloat {
        switch direction {
        case "N": return -75
        case "S": return 75
        default: return 0
        }
    }

    private func directionOffsetX(_ direction: String) -> CGFloat {
        switch direction {
        case "E": return 75
        case "W": return -75
        default: return 0
        }
    }

    private func updateContinuousAngle(_ newValue: Double) {
        var delta = newValue - lastAngle

        if delta > 180 {
            delta -= 360
        } else if delta < -180 {
            delta += 360
        }

        continuousAngle += delta
        lastAngle = newValue
    }
}

// MARK: - Info Pill

struct InfoPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(AppColors.Common.secondary)

            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}

// MARK: - Calibration Warning

struct CalibrationWarningView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.Prayers.prayerOrange)
                .font(.caption)

            VStack(alignment: .leading, spacing: 2) {
                Text("Calibration needed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.Common.primary)

                Text("Move your device in a figure-8 motion")
                    .font(.caption2)
                    .foregroundStyle(AppColors.Common.secondary)
            }

            Spacer()
        }
        .padding(10)
        .background(AppColors.Prayers.prayerOrange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    QiblaCompassView()
        .padding()
}
