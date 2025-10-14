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

    override init() {
        super.init()
        manager.delegate = self
    }

    func request() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.requestLocation()
    }

    var publisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        subject.eraseToAnyPublisher()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.last?.coordinate {
            subject.send(coord)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fallback: Toronto (or choose your app default)
        subject.send(CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832))
    }
}
