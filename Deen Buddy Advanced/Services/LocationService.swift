//
//  LocationService.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

// Services/LocationService.swift
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private let locationCacheKey = "cachedUserLocation"

    // Track if we've already sent cached location to avoid duplicates
    private var hasSentCachedLocation = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Sufficient for prayer times
    }

    /// Request location with smart caching
    /// - Parameter forceRefresh: If true, always fetches fresh location. If false, uses cache when appropriate.
    func request(forceRefresh: Bool = false) {
        let authStatus = manager.authorizationStatus

        // First-time permission request
        if authStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return // Wait for authorization callback
        }

        // If we have permission and forcing refresh, get fresh location
        if forceRefresh && (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways) {
            manager.requestLocation()
            return
        }

        // Try to use cached location first (for instant UI)
        if !hasSentCachedLocation, let cached = loadCachedLocation() {
            // Check cache age
            let cacheAge = Date().timeIntervalSince(cached.timestamp)

            // Use cache if less than 6 hours old
            if cacheAge < 6 * 3600 {
                hasSentCachedLocation = true
                subject.send(cached.coordinate)

                // Optionally refresh in background if cache is older than 1 hour
                if cacheAge > 3600 && (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.manager.requestLocation()
                    }
                }
                return
            }
        }

        // No valid cache or expired - request fresh location
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            manager.requestLocation()
        } else if let cached = loadCachedLocation() {
            // Permission denied but we have old cache - use it as last resort
            hasSentCachedLocation = true
            subject.send(cached.coordinate)
        }
    }

    /// Get cached location without triggering a request
    func getCachedLocationIfAvailable() -> CLLocationCoordinate2D? {
        guard let cached = loadCachedLocation() else { return nil }

        // Only return if less than 24 hours old
        let cacheAge = Date().timeIntervalSince(cached.timestamp)
        return cacheAge < 24 * 3600 ? cached.coordinate : nil
    }

    var publisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Location Caching

    private struct CachedLocation: Codable {
        let latitude: Double
        let longitude: Double
        let timestamp: Date

        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    private func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        let cached = CachedLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            timestamp: Date()
        )

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: locationCacheKey)
        }
    }

    private func loadCachedLocation() -> CachedLocation? {
        guard let data = UserDefaults.standard.data(forKey: locationCacheKey),
              let cached = try? JSONDecoder().decode(CachedLocation.self, from: data) else {
            return nil
        }
        return cached
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Only fetch location if authorized (not on denial)
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let coord = location.coordinate

        // Save to cache
        saveLocation(coord)

        // Send to subscribers
        subject.send(coord)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Try cached location first
        if let cached = loadCachedLocation() {
            subject.send(cached.coordinate)
            return
        }

        // Last resort fallback: Default location (Mecca, Saudi Arabia - more appropriate than Toronto)
        subject.send(CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262))
    }
}
