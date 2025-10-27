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
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width

            // Scale factors based on screen size
            let compassSize = min(screenWidth * 0.5, screenHeight * 0.25)
            let kaabaSize = compassSize * 0.15
            let arrowSize = compassSize * 0.525  // 1.5x larger than original 0.35
            let kaabaOffset = -compassSize * 0.58
            let dotOffset = -compassSize * 0.5

            VStack(spacing: screenHeight * 0.02) {
                Spacer()

                if vm.locationAvailable {
                    // Compass with Kaaba at top and rotating arrow
                    ZStack {
                        // Mosque icon at the top - ALWAYS FIXED at top
                        Image(systemName: "mosque.fill")
                            .font(.system(size: kaabaSize * 3.5, weight: .medium))
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .offset(y: kaabaOffset)

                        // Shortest path indicator (arc from arrow to Kaaba at top)
                        let arcFraction = abs(vm.angleDifference) / 360.0

                        Circle()
                            .trim(from: 0, to: arcFraction)
                            .stroke(
                                AppColors.Prayers.prayerBlue.opacity(0.5),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 4])
                            )
                            .frame(width: compassSize, height: compassSize)
                            .rotationEffect(.degrees(vm.angleDifference > 0 ? -90 : (-90 - abs(vm.angleDifference))))
                            .opacity(isAligned ? 0 : 1)

                        // Blue dot at arrow's current position (end of arc)
                        Circle()
                            .fill(AppColors.Prayers.prayerBlue)
                            .frame(width: 14, height: 14)
                            .offset(y: dotOffset)
                            .rotationEffect(.degrees(vm.angleDifference))
                            .opacity(isAligned ? 0 : 1)

                        // Center arrow - ROTATES to show direction difference
                        Image(systemName: "arrow.up")
                            .font(.system(size: arrowSize, weight: .bold))
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .rotationEffect(.degrees(vm.angleDifference), anchor: .center)
                    }
                    .frame(height: screenHeight * 0.4)
                } else {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(ArrowQiblaStrings.gettingLocation)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                    .frame(height: screenHeight * 0.4)
                }

                Spacer()

                // Direction and angle text at the bottom
                VStack(spacing: screenHeight * 0.015) {
                    // Direction instruction
                    Text(directionText)
                        .font(.system(size: min(24, screenHeight * 0.028)))
                        .fontWeight(.semibold)
                        .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Common.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    // Angle details
                    HStack(spacing: screenWidth * 0.04) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ArrowQiblaStrings.qiblaDirection)
                                .font(.caption)
                                .foregroundColor(AppColors.Common.secondary)
                            Text("\(Int(vm.qiblaBearing))°")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .frame(height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(ArrowQiblaStrings.currentHeading)
                                .font(.caption)
                                .foregroundColor(AppColors.Common.secondary)
                            Text("\(Int(vm.deviceHeading))°")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)

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
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, screenHeight * 0.015)
                    .padding(.horizontal, screenWidth * 0.04)
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
                .padding(.bottom, screenHeight * 0.02)
            }
            .padding(.horizontal, screenWidth * 0.04)
        }
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
