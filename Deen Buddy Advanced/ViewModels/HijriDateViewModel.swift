//
//  HijriDateViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Codex CLI on 2025-02-14.
//

import Foundation
import Combine
import CoreLocation

final class HijriDateViewModel: ObservableObject {
    @Published var hijriDateText: String = "-"
    @Published var gregorianDateText: String = "-"
    @Published var hijriShortDateText: String = "-"
    @Published var locationDescription: String?
    @Published var isLoading: Bool = true
    @Published var currentTimeZone: TimeZone = .current

    private let locationService = LocationService()
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()

    init() {
        bindLocationUpdates()
        locationService.request()
    }

    private func bindLocationUpdates() {
        locationService.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.handleLocation(coordinate)
            }
            .store(in: &cancellables)
    }

    private func handleLocation(_ coordinate: CLLocationCoordinate2D) {
        isLoading = true

        geocoder.cancelGeocode()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let fallbackTimeZone = TimeZone.current

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }

            let placemark = placemarks?.first
            let timeZone = placemark?.timeZone ?? fallbackTimeZone
            DispatchQueue.main.async {
                self.updateDateInformation(timeZone: timeZone, placemark: placemark)
            }
        }
    }

    private func updateDateInformation(timeZone: TimeZone, placemark: CLPlacemark?) {
        let date = Date()

        currentTimeZone = timeZone
        hijriDateText = HijriDateFormatter.hijriFormatter(using: timeZone).string(from: date)
        hijriShortDateText = HijriDateFormatter.hijriShortFormatter(using: timeZone).string(from: date)
        gregorianDateText = HijriDateFormatter.gregorianFormatter(using: timeZone).string(from: date)

        if let placemark {
            locationDescription = [placemark.locality, placemark.country]
                .compactMap { $0 }
                .joined(separator: ", ")
        } else {
            locationDescription = nil
        }

        isLoading = false
    }

    func hijriString(for date: Date) -> String {
        HijriDateFormatter.hijriFormatter(using: currentTimeZone).string(from: date)
    }

    func hijriShortString(for date: Date) -> String {
        HijriDateFormatter.hijriShortFormatter(using: currentTimeZone).string(from: date)
    }

    func gregorianString(for date: Date) -> String {
        HijriDateFormatter.gregorianFormatter(using: currentTimeZone).string(from: date)
    }
}

enum HijriDateFormatter {
    static func hijriFormatter(using timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = hijriLocale(for: Locale.current)
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter
    }

    static func hijriShortFormatter(using timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = hijriLocale(for: Locale.current)
        formatter.timeZone = timeZone
        formatter.dateFormat = "d, MMMM yyyy"
        return formatter
    }

    static func gregorianFormatter(using timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter
    }

    private static func hijriLocale(for base: Locale) -> Locale {
        if let languageCode = base.languageCode {
            return Locale(identifier: "\(languageCode)_SA")
        }
        return Locale(identifier: "en_SA")
    }
}
