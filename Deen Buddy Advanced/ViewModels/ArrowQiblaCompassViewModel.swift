//
//  ArrowQiblaCompassViewModel.swift
//  Deen Buddy Advanced
//
//  Arrow-based Qibla compass ViewModel
//

import Foundation
import CoreLocation
import Combine

final class ArrowQiblaCompassViewModel: ObservableObject {
    @Published private(set) var deviceHeading: Double = 0.0
    @Published private(set) var qiblaBearing: Double = 0.0
    @Published private(set) var angleDifference: Double = 0.0
    @Published private(set) var isCalibrationNeeded: Bool = false
    @Published private(set) var isActive: Bool = false
    @Published private(set) var locationAvailable: Bool = false

    private let compassService = CompassService()
    private let locationService = LocationService()
    private var bag = Set<AnyCancellable>()

    private var userLocation: CLLocationCoordinate2D?
    private var hasValidHeading: Bool = false

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
                guard let self = self else { return }

                // Mark that we have a valid heading (after first real update)
                self.hasValidHeading = true

                self.updateCompassData(deviceHeading: heading)
            }
            .store(in: &bag)

        // Listen to calibration status
        compassService.$isCalibrationNeeded
            .assign(to: &$isCalibrationNeeded)
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

        // Calculate Qibla bearing
        qiblaBearing = QiblaService.calculateQiblaBearing(from: coordinate)

        // Only show UI if we have a valid compass heading
        if hasValidHeading {
            locationAvailable = true
            // Update compass data with current heading
            updateCompassData(deviceHeading: deviceHeading)
        }
    }

    private func updateCompassData(deviceHeading: Double) {
        self.deviceHeading = deviceHeading

        // If we have location, show UI and calculate angle
        if userLocation != nil && !locationAvailable {
            locationAvailable = true
        }

        guard locationAvailable else { return }

        // Calculate the angle difference (how much to turn)
        var diff = qiblaBearing - deviceHeading

        // Normalize to -180 to 180 range for shortest path
        if diff > 180 {
            diff -= 360
        } else if diff < -180 {
            diff += 360
        }

        angleDifference = diff
    }

    deinit {
        stop()
    }
}
