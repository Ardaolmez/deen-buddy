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
        return String(format: ArrowQiblaStrings.turnDirectionFormat,direction, Int(absAngle) )
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width

            // Scale factors based on screen size - EVEN BIGGER compass
            let compassSize = min(screenWidth * 0.9, screenHeight * 0.45)  // Much larger: increased to 0.9 and 0.45
            let kaabaSize = compassSize * 0.1   // Smaller ratio for bigger compass
            let arrowSize = compassSize * 0.4   // Adjusted ratio for much bigger compass
            let kaabaOffset = -compassSize * 0.65  // Position Kaaba slightly above the circle
            let dotOffset = -compassSize * 0.5   // Keep same ratio for proper positioning

            VStack(spacing: screenHeight * 0.01) {  // Reduced spacing for tighter layout
                Spacer()

                if vm.locationAvailable {
                    // Compass with Kaaba at top and rotating arrow
                    ZStack {
                        // Mosque icon at the top - ALWAYS FIXED at top
                        Image(systemName: "building.2.fill")
                            .font(.system(size: kaabaSize * 1.2, weight: .medium))  // Increased multiplier for bigger compass
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .offset(y: kaabaOffset)

                        // Shortest path indicator (arc from arrow to Kaaba at top)
                        let arcFraction = abs(vm.angleDifference) / 360.0

                        Circle()
                            .trim(from: 0, to: arcFraction)
                            .stroke(
                                AppColors.Prayers.prayerBlue.opacity(0.5),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [12, 8])  // Even thicker stroke for bigger compass
                            )
                            .frame(width: compassSize, height: compassSize)
                            .rotationEffect(.degrees(vm.angleDifference > 0 ? -90 : (-90 - abs(vm.angleDifference))))
                            .opacity(isAligned ? 0 : 1)

                        // Blue dot at arrow's current position (end of arc)
                        Circle()
                            .fill(AppColors.Prayers.prayerBlue)
                            .frame(width: 18, height: 18)  // Larger dot for much bigger compass
                            .offset(y: dotOffset)
                            .rotationEffect(.degrees(vm.angleDifference))
                            .opacity(isAligned ? 0 : 1)

                        // Center arrow - ROTATES to show direction difference
                        Image(systemName: "arrow.up")
                            .font(.system(size: arrowSize, weight: .bold))
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .rotationEffect(.degrees(vm.angleDifference), anchor: .center)
                    }
                    .frame(height: screenHeight * 0.55)  // Much larger container for bigger compass
                } else {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(ArrowQiblaStrings.gettingLocation)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                    .frame(height: screenHeight * 0.55)  // Match the compass container height
                }

                // Reduced gap between compass and text
                Spacer()
                    .frame(height: screenHeight * 0.01)  // Much smaller gap

                // Direction and angle text at the bottom
                VStack(spacing: screenHeight * 0.01) {  // Reduced spacing for tighter text layout
                    // Direction instruction - MUCH BIGGER TEXT for visual recognition
                    Text(directionText)
                        .font(.system(size: min(40, screenHeight * 0.06)))  // Much larger: increased to 40 and 0.048
                        .fontWeight(.heavy)  // Even bolder than bold for maximum visual impact
                        .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Common.primary)
                        .lineLimit(2)  // Allow 2 lines for better text wrapping if needed
                        .minimumScaleFactor(0.7)  // Higher minimum scale to maintain readability
                        .multilineTextAlignment(.center)

                    // Angle details
                    HStack(spacing: screenWidth * 0.04) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ArrowQiblaStrings.qiblaDirection)
                                .font(.caption)
                                .foregroundColor(AppColors.Common.secondary.opacity(0))
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .frame(height: 40)



                    }
                    .padding(.vertical, screenHeight * 0.015)
                    .padding(.horizontal, screenWidth * 0.04)
                    .background(AppColors.Common.gray.opacity(0))
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
