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
            return "Aligned to Qibla"
        }

        let direction = vm.angleDifference > 0 ? "right" : "left"
        return "Turn \(Int(absAngle))° \(direction)"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if vm.locationAvailable {
                // Compass circle with Kaaba icon and arrow
                ZStack {
                    // Outer circle (compass boundary)
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)

                    // Kaaba icon at the Qibla direction
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .offset(y: -120)
                        .rotationEffect(.degrees(vm.angleDifference))

                    // Shortest path indicator (arc from arrow to Kaaba) - only show when not aligned
                    if !isAligned {
                        Circle()
                            .trim(from: 0, to: min(abs(vm.angleDifference) / 360, 0.5))
                            .stroke(
                                Color.blue.opacity(0.4),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 4])
                            )
                            .frame(width: 240, height: 240)
                            .rotationEffect(.degrees(-90)) // Start from top
                            .rotationEffect(.degrees(vm.angleDifference > 0 ? 0 : vm.angleDifference)) // Rotate to show shortest path
                    }

                    // Center arrow pointing up (north/forward)
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(isAligned ? .green : .blue)

                        Text("Device")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .shadow(color: isAligned ? .green.opacity(0.5) : .clear, radius: 20)
                }
                .animation(.easeInOut(duration: 0.3), value: isAligned)
                .animation(.easeInOut(duration: 0.2), value: vm.angleDifference)
            } else {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Getting location...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Direction and angle text at the bottom
            VStack(spacing: 12) {
                // Direction instruction
                Text(directionText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(isAligned ? .green : .primary)

                // Angle details
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Qibla Direction")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(vm.qiblaBearing))°")
                            .font(.headline)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Heading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(vm.deviceHeading))°")
                            .font(.headline)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Difference")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(abs(vm.angleDifference)))°")
                            .font(.headline)
                            .foregroundColor(isAligned ? .green : .primary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Compass accuracy indicator
                if vm.isCalibrationNeeded {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Low compass accuracy - calibrate your device")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
