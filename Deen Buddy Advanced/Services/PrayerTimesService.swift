//
//  PrayerTimesService.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//
// Services/PrayerTimesService.swift
import Foundation
import CoreLocation
import Adhan


struct DayTimes {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    let sunset: Date          // can map to pt.sunset if available, else maghrib
    let zawalStart: Date
    let zawalEnd: Date
}

struct PrayerTimesService {
    // Choose method for Pakistan
    private static var params: CalculationParameters = {
          var p = CalculationMethod.karachi.params
          p.madhab = .hanafi
          p.highLatitudeRule = .twilightAngle
          return p
      }()

      static func dayTimes(for coord: CLLocationCoordinate2D, on date: Date = Date()) -> DayTimes? {
          let cal = Calendar.current
          let comps = cal.dateComponents([.year, .month, .day], from: date)

          let c = Coordinates(latitude: coord.latitude, longitude: coord.longitude)
          guard let pt = PrayerTimes(coordinates: c, date: comps, calculationParameters: params) else {
              return nil
          }

          // Zawal window centered on Dhuhr (solar transit)
          let zawalWindowSeconds: TimeInterval = 11 * 60 // ~11 minutes (adjust to taste)
          let zawalStart = pt.dhuhr.addingTimeInterval(-zawalWindowSeconds / 2)
          let zawalEnd   = pt.dhuhr.addingTimeInterval(+zawalWindowSeconds / 2)

          // Some Adhan versions expose `pt.sunset`. If yours doesn't, use maghrib as a close proxy.
          #if canImport(Adhan)
          // If your version has `sunset`, keep this line; otherwise comment it out.
          let sunset: Date = (Mirror(reflecting: pt).children.first { $0.label == "sunset" }?.value as? Date) ?? pt.maghrib
          #else
          let sunset: Date = pt.maghrib
          #endif

          return DayTimes(
              fajr: pt.fajr,
              sunrise: pt.sunrise,
              dhuhr: pt.dhuhr,
              asr: pt.asr,
              maghrib: pt.maghrib,
              isha: pt.isha,
              sunset: sunset,
              zawalStart: zawalStart,
              zawalEnd: zawalEnd
          )
      }

      static func entries(for coord: CLLocationCoordinate2D, on date: Date = Date())
      -> (entries: [PrayerEntry], header: DayTimes)? {
          guard let dt = dayTimes(for: coord, on: date) else { return nil }
          return (
              [
                  PrayerEntry(name: .fajr,    time: dt.fajr),
                  PrayerEntry(name: .dhuhr,   time: dt.dhuhr),
                  PrayerEntry(name: .asr,     time: dt.asr),
                  PrayerEntry(name: .maghrib, time: dt.maghrib),
                  PrayerEntry(name: .isha,    time: dt.isha)
              ],
              dt
          )
      }

    /// Current and next prayer, excluding sunrise; next crosses to tomorrow if needed.
    static func currentAndNext(now: Date, entries: [PrayerEntry], coord: CLLocationCoordinate2D) -> (current: PrayerEntry?, next: PrayerEntry) {
        let sorted = entries.sorted { $0.time < $1.time }

        for i in 0..<sorted.count {
            if now < sorted[i].time {
                let current = (i == 0) ? nil : sorted[i-1]
                return (current, sorted[i])
            }
        }

        // After Isha → next is tomorrow's Fajr
        if let tomorrow = entriesForTomorrow(coord: coord, from: now)?.first(where: { $0.name == .fajr }) {
            return (sorted.last, tomorrow)
        }

        // Fallback (should not hit)
        return (sorted.last, sorted.first!)
    }

    private static func entriesForTomorrow(coord: CLLocationCoordinate2D, from now: Date) -> [PrayerEntry]? {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now),
              let (list, _) = entries(for: coord, on: tomorrow) else { return nil }
        return list
    }
}
