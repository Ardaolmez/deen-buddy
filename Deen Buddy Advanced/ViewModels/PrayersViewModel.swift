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
        bindLocation()
        location.request()
        loadCompleted()
        syncTodayToStoreIfNeeded()
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
        recomputeWeekStreak()   // ← add this line
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
        logger.setCompleted(name, !logger.isCompleted(name))

        // --- NEW: write to Core Data so PrayerRecordsViewModel sees it ---
        let isNowCompleted = completedToday.contains(name)
        let status: PrayerStatus = isNowCompleted ? computedStatus(for: name) : .notPrayed


        // Jumu'ah heuristic: only Friday + Dhuhr → inJamaah = true (when completed)
        let jumaah = isJumuah(name: name, on: Date()) && isNowCompleted

        recordsStore.upsert(
            day: Date(),
            prayer: name,
            status: status,
            inJamaah: jumaah
        )

        recomputeWeekStreak()
    }


    private func computedStatus(for name: PrayerName, now: Date = Date()) -> PrayerStatus {
        // find this prayer's scheduled time from today's entries
        guard let scheduled = entries.first(where: { $0.name == name })?.time else {
            return .onTime
        }
        // If user marks X minutes after scheduled time → late
        let lateAfterMinutes = 30  // tweak to your preference
        if now > scheduled.addingTimeInterval(TimeInterval(lateAfterMinutes * 60)) {
            return .late
        }
        return .onTime
    }

    private func isJumuah(name: PrayerName, on date: Date) -> Bool {
        name == .dhuhr && Calendar.current.component(.weekday, from: date) == 6 // Friday
    }

    private func syncTodayToStoreIfNeeded() {
        // If Core Data already has any row for today, skip (simple guard)
        let today = Date().startOfDay
        let existing = recordsStore.fetchRange(from: today, to: today)
        if !existing.isEmpty { return }

        // Write whatever is in completedToday
        for p in PrayerName.allCases {
            let isDone = completedToday.contains(p)
            let status: PrayerStatus = isDone ? .onTime : .notPrayed
            let jamaah = isJumuah(name: p, on: Date()) && isDone
            recordsStore.upsert(day: today, prayer: p, status: status, inJamaah: jamaah)
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
