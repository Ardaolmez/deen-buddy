//
//  CompassService.swift
//  Deen Buddy Advanced
//
//  Provides compass heading data using CLLocationManager
//

import CoreLocation
import Combine

final class CompassService: NSObject, ObservableObject {
    @Published private(set) var heading: Double = 0.0
    @Published private(set) var accuracy: Double = 0.0
    @Published private(set) var isCalibrationNeeded: Bool = false
    @Published private(set) var isActive: Bool = false

    private let locationManager = CLLocationManager()

    // Low-pass filter for smoothing
    private var filteredHeading: Double = 0.0
    private let filterAlpha: Double = 0.15 // Smoothing factor (0-1, lower = smoother)

    override init() {
        super.init()
        locationManager.delegate = self

        // Check if heading is available
        if !CLLocationManager.headingAvailable() {
            print("⚠️ Heading not available on this device")
        }
    }

    /// Start receiving compass updates
    func startUpdates() {
        guard !isActive else { return }
        guard CLLocationManager.headingAvailable() else {
            print("⚠️ Cannot start compass - heading not available")
            return
        }

        isActive = true

        // Configure heading filter (minimum change in degrees before update)
        locationManager.headingFilter = 1 // Update every 1 degree change

        // Set orientation (use the device's current orientation)
        // This can be adjusted based on your needs
        locationManager.headingOrientation = .portrait

        // Start heading updates
        locationManager.startUpdatingHeading()
    }

    /// Stop receiving compass updates
    func stopUpdates() {
        guard isActive else { return }

        isActive = false
        locationManager.stopUpdatingHeading()
    }

    deinit {
        stopUpdates()
    }
}

// MARK: - CLLocationManagerDelegate

extension CompassService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Use magnetic heading (you can use trueHeading if available and prefer true north)
        var headingValue = newHeading.magneticHeading

        // If true heading is available and valid, prefer it (more accurate)
        if newHeading.trueHeading >= 0 {
            headingValue = newHeading.trueHeading
        }

        // Apply low-pass filter for smoothing
        if filteredHeading == 0.0 {
            // Initialize filter
            filteredHeading = headingValue
        } else {
            // Handle angle wrapping (359° -> 0° transition)
            var delta = headingValue - filteredHeading
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }

            filteredHeading += delta * filterAlpha
            filteredHeading = (filteredHeading + 360).truncatingRemainder(dividingBy: 360)
        }

        // Update published properties on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.heading = self.filteredHeading

            // Heading accuracy (in degrees) - negative means invalid
            if newHeading.headingAccuracy >= 0 {
                // Convert accuracy to 0-1 scale
                // Good accuracy: 0-5 degrees
                // Medium: 5-15 degrees
                // Poor: 15+ degrees
                let accuracyDegrees = newHeading.headingAccuracy
                if accuracyDegrees <= 5 {
                    self.accuracy = 1.0
                } else if accuracyDegrees <= 15 {
                    self.accuracy = 0.66
                } else if accuracyDegrees <= 30 {
                    self.accuracy = 0.33
                } else {
                    self.accuracy = 0.1
                }
                self.isCalibrationNeeded = accuracyDegrees > 20
            } else {
                // Invalid accuracy
                self.accuracy = 0.0
                self.isCalibrationNeeded = true
            }
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // Return true to allow iOS to display calibration screen when needed
        return true
    }
}
