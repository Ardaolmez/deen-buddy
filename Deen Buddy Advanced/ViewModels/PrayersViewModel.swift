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
    private let logger = PrayerLogger()
    private let recordsStore: PrayerRecordsStore
    private let cache: PrayerTimesCache = UserDefaultsPrayerTimesCache()
    
    // MARK: - Weekly streak (days this week with all five prayed)
    @Published private(set) var weekStreakCount: Int = 0
    @Published private(set) var isPerfectWeek: Bool = false
    
    @Published private(set) var cityLine: String = AppStrings.prayers.locating
    @Published private(set) var header: DayTimes?
    @Published private(set) var entries: [PrayerEntry] = []

    @Published private(set) var currentPrayer: PrayerEntry?
    @Published private(set) var nextPrayer: PrayerEntry?
    @Published private(set) var countdownText: String = AppStrings.prayers.timeCountdownPlaceholder
    @Published private(set) var isBetweenSunriseAndDhuhr: Bool = false

    // completed state (per-day)
    @Published private(set) var completedToday: Set<PrayerName> = []

    private let location = LocationService()
    private var bag = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private var coord: CLLocationCoordinate2D?

    init(recordsStore: PrayerRecordsStore = CoreDataPrayerRecordsStore()) {
        self.recordsStore = recordsStore
        
        // 1) Try cached snapshot for instant UI
        if let snap = cache.loadToday() {
            self.cityLine = snap.cityLine
            self.header   = snap.header
            self.entries  = snap.entries

            // Get coordinate from cache for recompute
            if let cachedCoord = cache.getCachedCoordinate() {
                self.coord = cachedCoord
            }

            // derive current/next + countdown immediately
            self.recompute(now: Date())
        }

            // 2) Then proceed with live location + updates
        bindLocation()
        location.request()
        loadCompleted()
        
        // ✨ Do NOT mark all of today up-front. Only sync what's already completed.
            syncTodayCompletedOnLaunch()
            startTicker()
    }
    
    // MARK: - Toggle rules (today: only current/previous)
    func canMark(_ entry: PrayerEntry, now: Date = Date()) -> Bool {
        // Only for TODAY …
        guard Calendar.current.isDateInToday(entry.time) else { return false }
        // …and only current/previous prayers (time already reached)
        return entry.time <= now
    }



    /// A day is “completed” if all 5 prayers were marked done for that day in UserDefaults.
    /// A day is “completed” if every prayer has a non-`.notPrayed` record.
    /// Prefer Core Data (recordsStore). If a prayer has no record yet, fall back to
    /// the UserDefaults set you already keep for the Prayers screen.
    private func allPrayersCompleted(on day: Date) -> Bool {
        let d0 = Calendar.current.startOfDay(for: day)
        let udSet = completedSet(for: d0)   // fallback

        var sawAnyStoreRow = false
        for p in PrayerName.allCases {
            if let rec = recordsStore.fetch(day: d0, prayer: p) {
                sawAnyStoreRow = true
                if rec.statusEnum == .notPrayed { return false }
            } else {
                // No Core Data row yet → fall back to your per-day toggle set
                if !udSet.contains(p) { return false }
            }
        }
        // If we reached here, all five were either completed in store or toggled in UD.
        // (If both stores were empty, the UD check above returns false on the first prayer.)
        return true
    }


    // MARK: - Per-day completed sets in UserDefaults

    /// Build the per-day key (yyyyMMdd) for any date
    private func completedKey(for day: Date) -> String {
        let ymd = DateFormatter.cached("yyyyMMdd").string(from: day)
        return "\(AppStrings.prayers.completedKeyPrefix).\(ymd)"
    }

    /// Load the completion set for any day (defaults to empty)
    private func completedSet(for day: Date) -> Set<PrayerName> {
        let key = completedKey(for: day)
        guard let data = UserDefaults.standard.data(forKey: key),
              let set = try? JSONDecoder().decode(Set<PrayerName>.self, from: data) else {
            return []
        }
        return set
    }

    

    private func bindLocation() {
        location.publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] c in
                self?.handleLocationUpdate(c)
            }
            .store(in: &bag)
    }

    private func handleLocationUpdate(_ newCoord: CLLocationCoordinate2D) {
        // Always update coordinate reference
        coord = newCoord

        // Check if we should recalculate prayer times
        let (shouldRecalculate, _, _) = cache.shouldRecalculate(for: newCoord)

        if shouldRecalculate {
            reverseGeocode(newCoord)
            reload(for: newCoord)
        } else {
            // Just update the cached coordinate, don't recalculate prayer times
            cache.updateLocationOnly(coord: newCoord)

            // Still do reverse geocoding if city name is missing
            if cityLine.isEmpty || cityLine == "Locating..." {
                reverseGeocode(newCoord)
            }
        }
    }
    
    

    private func reload(for c: CLLocationCoordinate2D) {
        guard let (list, header) = PrayerTimesService.entries(for: c) else { return }
        self.header = header
        self.entries = list
        recompute(now: Date())
        recomputeWeekStreak()   // ← add this line
        
        // ⬅️ Save snapshot (use latest cityLine known; it will be refined by reverseGeocode)
          cache.saveToday(cityLine: self.cityLine, header: header, entries: list, coord: c)
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

//    private func reverseGeocode(_ c: CLLocationCoordinate2D) {
//        let g = CLGeocoder()
//        g.reverseGeocodeLocation(CLLocation(latitude: c.latitude, longitude: c.longitude)) { [weak self] placemarks, _ in
//            let p = placemarks?.first
//            let city = p?.locality ?? p?.subAdministrativeArea ?? AppStrings.prayers.yourArea
//            let country = p?.isoCountryCode ?? p?.country ?? ""
//            self?.cityLine = country.isEmpty ? city : "\(city), \(country)"
//            
//            if let header = self.header {
//                        self.cache.saveToday(cityLine: self.cityLine, header: header, entries: self.entries, coord: c)
//                    }
//        }
//        
//        
//    }
    
    private func reverseGeocode(_ c: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: c.latitude, longitude: c.longitude)) { [weak self] placemarks, error in
            guard let self = self else { return }

            // If geocoder failed, keep previous cityLine and bail gracefully
            if let _ = error {
                return
            }

            let p = placemarks?.first
            let city    = (p?.locality ?? p?.subAdministrativeArea ?? AppStrings.prayers.yourArea).trimmingCharacters(in: .whitespacesAndNewlines)
            let country = ((p?.isoCountryCode ?? p?.country) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            // Compose "City, CC" only if we have a country string
            let newCityLine = country.isEmpty ? city : "\(city), \(country)"

            DispatchQueue.main.async {
                // Only update & save if the label changed
                let didChange = (self.cityLine != newCityLine)
                self.cityLine = newCityLine

                // Save to cache if we have times already and something changed
                if didChange, let header = self.header, !self.entries.isEmpty {
                    self.cache.saveToday(cityLine: self.cityLine,
                                         header: header,
                                         entries: self.entries,
                                         coord: c)
                }
            }
        }
    }


    // MARK: - Completed prayers (persist per day)


    // Toggle
    func toggleCompleted(_ name: PrayerName) {
        let now = Date()
        let wasCompleted = completedToday.contains(name)

        // Flip local state + UD + your logger
        if wasCompleted { completedToday.remove(name) } else { completedToday.insert(name) }
        saveCompleted()
        logger.setCompleted(name, !wasCompleted)

        // Find schedule time for this prayer
        let scheduled = entries.first(where: { $0.name == name })?.time

        if !wasCompleted {
            // Marking as completed → write an onTime/late row
            let status = computedStatus(for: name, now: now)
            let jumaah = isJumuah(name: name, on: now)
            recordsStore.upsert(day: now, prayer: name, status: status, inJamaah: jumaah)
        } else {
            // Unmarking
            if let scheduled {
                let grace: TimeInterval = 30 * 60 // 30 minutes
                if now < scheduled + grace {
                    // It's before (or within grace of) scheduled → treat as "no data"
                    recordsStore.delete(day: now, prayer: name)
                } else {
                    // After scheduled+grace → explicitly mark as missed
                    recordsStore.upsert(day: now, prayer: name, status: .notPrayed, inJamaah: false)
                }
            } else {
                // No schedule found → safest is delete (no data)
                recordsStore.delete(day: now, prayer: name)
            }
        }

        recomputeWeekStreak()
    }


    private func computedStatus(for name: PrayerName, now: Date = Date()) -> PrayerStatus {
        guard let scheduled = entries.first(where: { $0.name == name })?.time else {
            return .onTime
        }
        let lateAfterMinutes = 30
        return now > scheduled.addingTimeInterval(TimeInterval(lateAfterMinutes * 60)) ? .late : .onTime
    }

    private func isJumuah(name: PrayerName, on date: Date) -> Bool {
        name == .dhuhr && Calendar.current.component(.weekday, from: date) == 6 // Friday
    }

    private func syncTodayCompletedOnLaunch(now: Date = Date()) {
        // Only write rows for prayers the user already marked completed today.
        for p in completedToday {
            // On launch, treat them as "onTime" unless already very late.
            let status = computedStatus(for: p, now: now)
            let jamaah = isJumuah(name: p, on: now)
            recordsStore.upsert(day: now, prayer: p, status: status, inJamaah: jamaah)
        }
    }
    
    
    

    func isCompleted(_ name: PrayerName) -> Bool {
//        completedToday.contains(name)
        logger.isCompleted(name)
        
    }

    // Today-only versions (what you already had), unchanged API
    private var completedKey: String {
        completedKey(for: Date())
    }

    private func loadCompleted() {
        completedToday = completedSet(for: Date())
    }

    private func saveCompleted() {
        let key = completedKey(for: Date())
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
    
    // MARK: - Weekly streak (days this week with all five prayed)
    func recomputeWeekStreak() {
        let (start, _, todayIdx) = weekBounds()

        // Build this week's 7-day completion booleans (Mon…Sun)
        var week: [Bool] = Array(repeating: false, count: 7)
        for i in 0..<7 {
            let day = Calendar.current.date(byAdding: .day, value: i, to: start)!
            week[i] = allPrayersCompleted(on: day)
        }

        // Count only up to today (no future days in the streak)
        weekStreakCount = week.prefix(todayIdx + 1).filter { $0 }.count
        isPerfectWeek   = week.prefix(todayIdx + 1).allSatisfy { $0 }
    }

    /// Monday-first 7-slot array that the StreakCard consumes
    var streakWeekStatus: [Bool] {
        let (start, _, _) = weekBounds()
        var week: [Bool] = Array(repeating: false, count: 7)
        for i in 0..<7 {
            let day = Calendar.current.date(byAdding: .day, value: i, to: start)!
            week[i] = allPrayersCompleted(on: day)
        }
        return week
    }

    
    // MARK: - Week helpers
    private func weekBounds(for date: Date = Date()) -> (start: Date, end: Date, todayIndex: Int) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)

        // ISO week start (Monday)
        var comp = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comp.weekday = 2 // Monday
        let start = cal.startOfDay(for: cal.date(from: comp) ?? today)

        let end = cal.date(byAdding: .day, value: 6, to: start)!   // Sunday end-of-week
        // Convert weekday (Sun=1) -> Mon=0…Sun=6
        let todayIdx = (cal.component(.weekday, from: today) + 5) % 7
        return (start, end, todayIdx)
    }

}

private extension DateFormatter {
    static func cached(_ fmt: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = fmt
        return f
    }
}
