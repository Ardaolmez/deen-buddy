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

            // Scale factors optimized for 68% container size - larger compass with bigger elements
            let compassSize = min(screenWidth * 0.88, screenHeight * 0.48)  // Increased for 68% container
            let kaabaSize = compassSize * 0.11   // Proportional mosque icon size
            let arrowSize = compassSize * 0.38   // Larger arrow for better visibility
            let kaabaOffset = -compassSize * 0.62  // Position Kaaba above the circle
            let dotOffset = -compassSize * 0.49   // Proportional dot positioning

            VStack(spacing: screenHeight * 0.01) {  // Reduced spacing for tighter layout
                Spacer()

                if vm.locationAvailable {
                    // Compass with Kaaba at top and rotating arrow
                    ZStack {
                        // Mosque icon at the top - ALWAYS FIXED at top
                        Text("🕌")
                            .font(.system(size: kaabaSize * 1.3))  // Increased multiplier for 68% compass
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .offset(y: kaabaOffset)

                        // Shortest path indicator (arc from arrow to Kaaba at top)
                        let arcFraction = abs(vm.angleDifference) / 360.0

                        Circle()
                            .trim(from: 0, to: arcFraction)
                            .stroke(
                                AppColors.Prayers.prayerBlue.opacity(0.5),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round, dash: [14, 10])  // Thicker stroke for 68% compass
                            )
                            .frame(width: compassSize, height: compassSize)
                            .rotationEffect(.degrees(vm.angleDifference > 0 ? (-90 - abs(vm.angleDifference)) : -90))
                            .opacity(isAligned ? 0 : 1)

                        // Blue dot at arrow's current position (end of arc)
                        Circle()
                            .fill(AppColors.Prayers.prayerBlue)
                            .frame(width: 20, height: 20)  // Larger dot for 68% compass
                            .offset(y: dotOffset)
                            .rotationEffect(.degrees(-vm.angleDifference))
                            .opacity(isAligned ? 0 : 1)

                        // Center arrow - ROTATES to show direction difference
                        Image(systemName: "arrow.up")
                            .font(.system(size: arrowSize, weight: .bold))
                            .foregroundColor(isAligned ? AppColors.Prayers.prayerGreen : AppColors.Prayers.prayerBlue)
                            .rotationEffect(.degrees(-vm.angleDifference), anchor: .center)
                    }
                    .frame(height: screenHeight * 0.58)  // Optimized for 68% container
                } else {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(ArrowQiblaStrings.gettingLocation)
                            .font(.caption)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                    .frame(height: screenHeight * 0.58)  // Match the compass container height
                }

                // Reduced gap between compass and text
                Spacer()
                    .frame(height: screenHeight * 0.01)  // Much smaller gap

                // Direction and angle text at the bottom
                VStack(spacing: screenHeight * 0.01) {  // Reduced spacing for tighter text layout
                    // Direction instruction - Bigger text for 68% compass container
                    Text(directionText)
                        .font(.system(size: min(38, screenHeight * 0.058)))  // Increased to 38pt for bigger text
                        .fontWeight(.heavy)  // Heavy weight for maximum visibility
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
