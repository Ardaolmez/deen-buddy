//
//  QiblaCompassViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for Qibla compass functionality
//

import Foundation
import CoreLocation
import Combine

final class QiblaCompassViewModel: ObservableObject {
    @Published private(set) var qiblaBearing: Double = 0.0
    @Published private(set) var relativeQiblaAngle: Double = 0.0
    @Published private(set) var distanceToKaaba: Double = 0.0
    @Published private(set) var distanceText: String = "..."
    @Published private(set) var isCalibrationNeeded: Bool = false
    @Published private(set) var isActive: Bool = false
    @Published private(set) var locationAvailable: Bool = false
    @Published private(set) var compassAccuracy: Double = 0.0

    private let compassService = CompassService()
    private let locationService = LocationService()
    private var bag = Set<AnyCancellable>()

    private var userLocation: CLLocationCoordinate2D?

    init() {
        bindCompassService()
        bindLocationService()
    }

    // MARK: - Public Methods

    func start() {
        guard !isActive else { return }
        isActive = true

        // Request location
        locationService.request()

        // Start compass updates
        compassService.startUpdates()
    }

    func stop() {
        guard isActive else { return }
        isActive = false

        compassService.stopUpdates()
    }

    // MARK: - Private Methods

    private func bindCompassService() {
        // Listen to compass heading changes
        compassService.$heading
            .sink { [weak self] heading in
                self?.updateQiblaDirection(compassHeading: heading)
            }
            .store(in: &bag)

        // Listen to calibration status
        compassService.$isCalibrationNeeded
            .assign(to: &$isCalibrationNeeded)

        // Listen to compass accuracy
        compassService.$accuracy
            .assign(to: &$compassAccuracy)
    }

    private func bindLocationService() {
        locationService.publisher
            .sink { [weak self] coordinate in
                self?.handleLocationUpdate(coordinate)
            }
            .store(in: &bag)
    }

    private func handleLocationUpdate(_ coordinate: CLLocationCoordinate2D) {
        userLocation = coordinate
        locationAvailable = true

        // Calculate Qibla bearing and distance
        qiblaBearing = QiblaService.calculateQiblaBearing(from: coordinate)
        distanceToKaaba = QiblaService.calculateDistanceToKaaba(from: coordinate)
        distanceText = QiblaService.formatDistance(distanceToKaaba)

        // Update relative angle with current compass heading
        if let heading = compassService.heading as Double? {
            updateQiblaDirection(compassHeading: heading)
        }
    }

    private func updateQiblaDirection(compassHeading: Double) {
        guard let location = userLocation else { return }

        // Calculate relative angle to Qibla
        relativeQiblaAngle = QiblaService.calculateRelativeQiblaDirection(
            from: location,
            deviceHeading: compassHeading
        )
    }

    // MARK: - Computed Properties

    /// Formatted Qibla bearing in degrees
    var qiblaBearingText: String {
        return String(format: "%.0f°", qiblaBearing)
    }

    /// User-friendly compass direction (N, NE, E, SE, S, SW, W, NW)
    var qiblaDirectionText: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((qiblaBearing + 22.5) / 45.0) % 8
        return directions[index]
    }

    /// Is the device pointing roughly toward Qibla? (within 15 degrees)
    var isPointingTowardQibla: Bool {
        return abs(relativeQiblaAngle) < 15.0
    }

    /// Accuracy level text
    var accuracyText: String {
        if compassAccuracy >= 0.8 {
            return "High accuracy"
        } else if compassAccuracy >= 0.5 {
            return "Medium accuracy"
        } else if compassAccuracy >= 0.2 {
            return "Low accuracy"
        } else {
            return "Calibration needed"
        }
    }

    deinit {
        stop()
    }
}
