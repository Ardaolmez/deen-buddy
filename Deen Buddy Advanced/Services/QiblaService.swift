//
//  QiblaService.swift
//  Deen Buddy Advanced
//
//  Calculates Qibla direction (bearing to Kaaba) from any location
//

import CoreLocation
import Foundation

final class QiblaService {
    // Kaaba coordinates in Mecca, Saudi Arabia
    static let kaabaCoordinate = CLLocationCoordinate2D(
        latitude: 21.4225,   // 21.4225°N
        longitude: 39.8262   // 39.8262°E
    )

    /// Calculate the Qibla bearing (direction to Kaaba) from a given location
    /// Returns bearing in degrees (0-360, where 0 = North, 90 = East, 180 = South, 270 = West)
    static func calculateQiblaBearing(from userLocation: CLLocationCoordinate2D) -> Double {
        let kaabaLat = kaabaCoordinate.latitude.toRadians()
        let kaabaLon = kaabaCoordinate.longitude.toRadians()
        let userLat = userLocation.latitude.toRadians()
        let userLon = userLocation.longitude.toRadians()

        // Spherical trigonometry formula for great circle bearing
        let lonDelta = kaabaLon - userLon
        let y = sin(lonDelta) * cos(kaabaLat)
        let x = cos(userLat) * sin(kaabaLat) - sin(userLat) * cos(kaabaLat) * cos(lonDelta)
        let bearing = atan2(y, x)

        // Convert to degrees and normalize to 0-360
        let degrees = bearing.toDegrees()
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Calculate the great circle distance to Kaaba in kilometers
    static func calculateDistanceToKaaba(from userLocation: CLLocationCoordinate2D) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let kaabaCLLocation = CLLocation(latitude: kaabaCoordinate.latitude, longitude: kaabaCoordinate.longitude)

        // CLLocation's distance method uses the haversine formula
        let distanceInMeters = userCLLocation.distance(from: kaabaCLLocation)
        return distanceInMeters / 1000.0 // Convert to kilometers
    }

    /// Calculate the Qibla direction relative to the device's current heading
    /// - Parameters:
    ///   - userLocation: User's current location
    ///   - deviceHeading: Current device compass heading (0-360)
    /// - Returns: Angle in degrees to rotate to point toward Qibla (-180 to 180)
    static func calculateRelativeQiblaDirection(
        from userLocation: CLLocationCoordinate2D,
        deviceHeading: Double
    ) -> Double {
        let qiblaBearing = calculateQiblaBearing(from: userLocation)

        // Calculate relative angle
        var relativeAngle = qiblaBearing - deviceHeading

        // Normalize to -180 to 180
        if relativeAngle > 180 {
            relativeAngle -= 360
        } else if relativeAngle < -180 {
            relativeAngle += 360
        }

        return relativeAngle
    }

    /// Format distance with appropriate units (km or m)
    static func formatDistance(_ distanceKm: Double) -> String {
        if distanceKm < 1.0 {
            let meters = Int(distanceKm * 1000)
            return "\(meters) m"
        } else if distanceKm < 10.0 {
            return String(format: "%.1f km", distanceKm)
        } else {
            return String(format: "%.0f km", distanceKm)
        }
    }
}

// MARK: - Helper Extensions

private extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }

    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
