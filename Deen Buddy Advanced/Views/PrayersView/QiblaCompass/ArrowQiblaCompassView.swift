import SwiftUI
import CoreLocation
import Combine

struct ArrowQiblaCompassView: View {
    @StateObject private var vm = ArrowQiblaCompassViewModel()

    // Check if aligned (within -2 to +2 degrees)
    private var isAligned: Bool {
        abs(vm.angleDifference) <= 2
    }

    // Direction text (e.g., "Turn 75° left")
    private var directionText: String {
        let absAngle = abs(vm.angleDifference)

        if isAligned {
            return ArrowQiblaStrings.alignedToQibla
        }

        let direction = vm.angleDifference > 0 ? ArrowQiblaStrings.right : ArrowQiblaStrings.left
        return String(format: ArrowQiblaStrings.turnDirectionFormat, Int(absAngle), direction)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if vm.locationAvailable {
                // Compass with Kaaba at top and rotating arrow
                ZStack {
                    // Kaaba icon at the top - ALWAYS FIXED at top
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 30))
                        .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Common.black)
                        .offset(y: -140)

                    // Shortest path indicator (arc from arrow to Kaaba at top)
                    // Calculate arc parameters
                    let arcFraction = abs(vm.angleDifference) / 360.0

                    Circle()
                        .trim(from: 0, to: arcFraction)
                        .stroke(
                            AppColors.Prayers.prayerBlue.opacity(0.5),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 4])
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(vm.angleDifference > 0 ? -90 : (-90 - abs(vm.angleDifference))))
                        .opacity(isAligned ? 0 : 1)

                    // Blue dot at arrow's current position (end of arc)
                    Circle()
                        .fill(AppColors.Prayers.prayerBlue)
                        .frame(width: 14, height: 14)
                        .offset(y: -120)
                        .rotationEffect(.degrees(vm.angleDifference))
                        .opacity(isAligned ? 0 : 1)

                    // Center arrow - ROTATES to show direction difference
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)

                        Text(ArrowQiblaStrings.device)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                    .rotationEffect(.degrees(vm.angleDifference), anchor: .center)
                }
            } else {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                    Text(ArrowQiblaStrings.gettingLocation)
                        .font(.caption)
                        .foregroundColor(AppColors.Common.secondary)
                }
            }

            Spacer()

            // Direction and angle text at the bottom
            VStack(spacing: 12) {
                // Direction instruction
                Text(directionText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Common.primary)

                // Angle details
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArrowQiblaStrings.qiblaDirection)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                        Text("\(Int(vm.qiblaBearing))°")
                            .font(.headline)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArrowQiblaStrings.currentHeading)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                        Text("\(Int(vm.deviceHeading))°")
                            .font(.headline)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArrowQiblaStrings.difference)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                        Text("\(Int(abs(vm.angleDifference)))°")
                            .font(.headline)
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Common.primary)
                    }
                }
                .padding()
                .background(AppColors.Common.gray.opacity(0.1))
                .cornerRadius(12)

                // Compass accuracy indicator
                if vm.isCalibrationNeeded {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.Prayers.prayerOrange)
                        Text(ArrowQiblaStrings.lowAccuracyWarning)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .padding()
        .onAppear {
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
    }
}

#Preview {
    ArrowQiblaCompassView()
}
