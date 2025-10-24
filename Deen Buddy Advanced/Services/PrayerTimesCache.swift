//
//  PrayerTimesCache.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/23/25.
//

// Services/PrayerTimesCache.swift
import Foundation
import CoreLocation

// MARK: - Codable snapshots

private struct CachedDayTimes: Codable {
    let fajr: Date, sunrise: Date, dhuhr: Date, asr: Date, maghrib: Date, isha: Date
    let sunset: Date, zawalStart: Date, zawalEnd: Date
}
private struct CachedPrayerEntry: Codable {
    let name: String
    let time: Date
}
private struct PrayerTimesSnapshot: Codable {
    let yyyymmdd: String
    let lat: Double
    let lon: Double
    let cityLine: String
    let header: CachedDayTimes
    let entries: [CachedPrayerEntry]
    let savedAt: Date
}

// MARK: - Cache protocol

protocol PrayerTimesCache {
    func loadToday() -> (cityLine: String, header: DayTimes, entries: [PrayerEntry])?
    func saveToday(cityLine: String, header: DayTimes, entries: [PrayerEntry], coord: CLLocationCoordinate2D)

    // Smart location methods
    func shouldRecalculate(for newCoord: CLLocationCoordinate2D) -> (shouldRecalculate: Bool, distance: Double?, reason: String)
    func updateLocationOnly(coord: CLLocationCoordinate2D)
    func getCachedCoordinate() -> CLLocationCoordinate2D?
}

final class UserDefaultsPrayerTimesCache: PrayerTimesCache {
    private let key = "prayerTimesCache.latest"
    private let roundPlaces = 2 // ~1.1km; bump to 3 if you want tighter

    func loadToday() -> (cityLine: String, header: DayTimes, entries: [PrayerEntry])? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let snap = try? JSONDecoder().decode(PrayerTimesSnapshot.self, from: data)
        else { return nil }

        // Only use if for today
        let todayKey = Self.ymd(Date())
        guard snap.yyyymmdd == todayKey else { return nil }

        // Rehydrate
        let header = DayTimes(
            fajr: snap.header.fajr, sunrise: snap.header.sunrise, dhuhr: snap.header.dhuhr,
            asr: snap.header.asr, maghrib: snap.header.maghrib, isha: snap.header.isha,
            sunset: snap.header.sunset, zawalStart: snap.header.zawalStart, zawalEnd: snap.header.zawalEnd
        )
        let entries: [PrayerEntry] = snap.entries.compactMap { e in
            guard let name = PrayerName(rawValue: e.name) else { return nil }
            return PrayerEntry(name: name, time: e.time)
        }
        return (snap.cityLine, header, entries)
    }

    func saveToday(cityLine: String, header: DayTimes, entries: [PrayerEntry], coord: CLLocationCoordinate2D) {
        let snap = PrayerTimesSnapshot(
            yyyymmdd: Self.ymd(Date()),
            lat: coord.latitude.rounded(places: roundPlaces),
            lon: coord.longitude.rounded(places: roundPlaces),
            cityLine: cityLine,
            header: CachedDayTimes(
                fajr: header.fajr, sunrise: header.sunrise, dhuhr: header.dhuhr, asr: header.asr,
                maghrib: header.maghrib, isha: header.isha, sunset: header.sunset,
                zawalStart: header.zawalStart, zawalEnd: header.zawalEnd
            ),
            entries: entries.map { CachedPrayerEntry(name: $0.name.rawValue, time: $0.time) },
            savedAt: Date()
        )
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func ymd(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f.string(from: d)
    }

    // MARK: - Smart Location Methods
    func shouldRecalculate(for newCoord: CLLocationCoordinate2D) -> (shouldRecalculate: Bool, distance: Double?, reason: String) {
        // Get current cached data
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(PrayerTimesSnapshot.self, from: data) else {
            return (true, nil, "No cached data")
        }

        // Check if cache is for today
        let todayKey = Self.ymd(Date())
        guard snap.yyyymmdd == todayKey else {
            return (true, nil, "Cache is from different day")
        }

        // Calculate distance from cached location
        let cachedLocation = CLLocation(latitude: snap.lat, longitude: snap.lon)
        let newLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
        let distance = cachedLocation.distance(from: newLocation)

        // Smart thresholds
        if distance < 100 {
            return (false, distance, "GPS noise (<100m)")
        } else if distance < 500 {
            return (false, distance, "Same area (<500m)")
        } else if distance < 2000 {
            return (false, distance, "Nearby location (<2km)")
        } else if distance < 10000 {
            return (true, distance, "Different area (>2km)")
        } else {
            return (true, distance, "Significant location change (>10km)")
        }
    }

    func updateLocationOnly(coord: CLLocationCoordinate2D) {
        // Update only the coordinate in existing cache
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(PrayerTimesSnapshot.self, from: data) else {
            return
        }

        // Create new snapshot with updated coordinates
        let updatedSnap = PrayerTimesSnapshot(
            yyyymmdd: snap.yyyymmdd,
            lat: coord.latitude,
            lon: coord.longitude,
            cityLine: snap.cityLine,
            header: snap.header,
            entries: snap.entries,
            savedAt: Date()
        )

        if let updatedData = try? JSONEncoder().encode(updatedSnap) {
            UserDefaults.standard.set(updatedData, forKey: key)
        }
    }

    func getCachedCoordinate() -> CLLocationCoordinate2D? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(PrayerTimesSnapshot.self, from: data) else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: snap.lat, longitude: snap.lon)
    }
}

private extension Double {
    func rounded(places p: Int) -> Double {
        let m = pow(10.0, Double(p))
        return (self * m).rounded() / m
    }
}
