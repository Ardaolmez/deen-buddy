//
//  PrayersViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

// ViewModels/PrayersViewModel.swift
import Foundation
import Combine
import CoreLocation
import WidgetKit



final class PrayersViewModel: ObservableObject {
    @Published private(set) var cityLine: String = AppStrings.prayers.locating
    @Published private(set) var header: DayTimes?
    @Published private(set) var entries: [PrayerEntry] = []

    @Published private(set) var currentPrayer: PrayerEntry?
    @Published private(set) var nextPrayer: PrayerEntry?
    @Published private(set) var countdownText: String = "--:--:--"
    @Published private(set) var isBetweenSunriseAndDhuhr: Bool = false

    // completed state (per-day)
    @Published private(set) var completedToday: Set<PrayerName> = []

    private let location = LocationService()
    private var bag = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private var coord: CLLocationCoordinate2D?

    init() {
        bindLocation()
        location.request()
        loadCompleted()
        startTicker()
    }

    private func bindLocation() {
        location.publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] c in
                self?.coord = c
                self?.reverseGeocode(c)
                self?.reload(for: c)
            }
            .store(in: &bag)
    }

    private func reload(for c: CLLocationCoordinate2D) {
        guard let (list, header) = PrayerTimesService.entries(for: c) else { return }
        self.header = header
        self.entries = list
        recompute(now: Date())
    }

    private func startTicker() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in self?.recompute(now: now) }
    }

    private func recompute(now: Date) {
        guard let c = coord else { return }
        guard let h = header else { return }

        // current / next (excluding sunrise)
        let pair = PrayerTimesService.currentAndNext(now: now, entries: entries, coord: c)
        currentPrayer = pair.current
        nextPrayer = pair.next

        // between sunrise and Dhuhr? → hide "current"
        isBetweenSunriseAndDhuhr = (now >= h.sunrise && now < h.dhuhr)
        if isBetweenSunriseAndDhuhr { currentPrayer = nil }

        // countdown always to `nextPrayer` (even if tomorrow)
        if let next = nextPrayer {
            let remain = max(0, Int(next.time.timeIntervalSince(now)))
            countdownText = Self.hhmmss(remain)
        } else {
            countdownText = AppStrings.prayers.countdownPlaceholder
        }

        // Save data for widget
        saveDataForWidget()
    }

    private static func hhmmss(_ secs: Int) -> String {
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func reverseGeocode(_ c: CLLocationCoordinate2D) {
        let g = CLGeocoder()
        g.reverseGeocodeLocation(CLLocation(latitude: c.latitude, longitude: c.longitude)) { [weak self] placemarks, _ in
            let p = placemarks?.first
            let city = p?.locality ?? p?.subAdministrativeArea ?? AppStrings.prayers.yourArea
            let country = p?.isoCountryCode ?? p?.country ?? ""
            self?.cityLine = country.isEmpty ? city : "\(city), \(country)"
        }
    }

    // MARK: - Completed prayers (persist per day)

    func toggleCompleted(_ name: PrayerName) {
        if completedToday.contains(name) { completedToday.remove(name) }
        else { completedToday.insert(name) }
        saveCompleted()
    }

    func isCompleted(_ name: PrayerName) -> Bool {
        completedToday.contains(name)
    }

    private var completedKey: String {
        let ymd = DateFormatter.cached("yyyyMMdd").string(from: Date())
        return "prayers.completed.\(ymd)"
    }

    private func loadCompleted() {
        let key = completedKey
        if let data = UserDefaults.standard.data(forKey: key),
           let set = try? JSONDecoder().decode(Set<PrayerName>.self, from: data) {
            completedToday = set
        }
    }

    private func saveCompleted() {
        let key = completedKey
        if let data = try? JSONEncoder().encode(completedToday) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // MARK: - Widget Data Saving

    private func saveDataForWidget() {
        guard let next = nextPrayer else { return }

        // Create all prayers info
        let allPrayersInfo = entries.map { entry in
            PrayerInfo(
                prayerKey: entry.name.rawValue,  // "fajr", "dhuhr", etc.
                time: entry.time,
                icon: iconForPrayer(entry.name),
                isCompleted: isCompleted(entry.name)
            )
        }

        // Create widget data
        let widgetData = PrayerWidgetData(
            nextPrayerKey: next.name.rawValue,
            nextPrayerTime: next.time,
            nextPrayerIcon: iconForPrayer(next.name),
            city: extractCity(from: cityLine),
            country: extractCountry(from: cityLine),
            allPrayers: allPrayersInfo,
            lastUpdated: Date()
        )

        // Save to shared storage
        UserDefaults.shared.savePrayerData(widgetData)

        // Tell widgets to reload
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func iconForPrayer(_ prayer: PrayerName) -> String {
        switch prayer {
        case .fajr: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }

    private func extractCity(from cityLine: String) -> String {
        let components = cityLine.split(separator: ",")
        return String(components.first ?? "")
    }

    private func extractCountry(from cityLine: String) -> String {
        let components = cityLine.split(separator: ",")
        return components.count > 1 ? String(components.last ?? "").trimmingCharacters(in: .whitespaces) : ""
    }
}

private extension DateFormatter {
    static func cached(_ fmt: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = fmt
        return f
    }
}
