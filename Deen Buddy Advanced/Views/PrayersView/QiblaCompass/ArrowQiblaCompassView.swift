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
                // Compass with Kaaba at top and rotating arrow
                ZStack {
                    // Kaaba icon at the top - ALWAYS FIXED at top
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 30))
                        .foregroundColor(isAligned ? .green : .black)
                        .offset(y: -140)

                    // Shortest path indicator (arc from arrow to Kaaba at top)
                    // Calculate arc parameters
                    let arcFraction = abs(vm.angleDifference) / 360.0

                    Circle()
                        .trim(from: 0, to: arcFraction)
                        .stroke(
                            Color.blue.opacity(0.5),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 4])
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(vm.angleDifference > 0 ? -90 : (-90 - abs(vm.angleDifference))))
                        .opacity(isAligned ? 0 : 1)

                    // Blue dot at arrow's current position (end of arc)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                        .offset(y: -120)
                        .rotationEffect(.degrees(vm.angleDifference))
                        .opacity(isAligned ? 0 : 1)

                    // Center arrow - ROTATES to show direction difference
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(isAligned ? .green : .blue)

                        Text("Device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .rotationEffect(.degrees(vm.angleDifference), anchor: .center)
                }
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
