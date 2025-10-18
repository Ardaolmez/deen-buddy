//
//  PrayerRecordsStore.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import CoreData

protocol PrayerRecordsStore {
    func upsert(day: Date, prayer: PrayerName, status: PrayerStatus, inJamaah: Bool)
    func fetch(day: Date, prayer: PrayerName) -> PrayerRecord?
    func fetchRange(from: Date, to: Date) -> [PrayerRecord]
    func dailyMatrix(from: Date, to: Date) -> [Date: [PrayerName: PrayerRecord]]
}

final class CoreDataPrayerRecordsStore: PrayerRecordsStore {
    private let ctx: NSManagedObjectContext
    init(ctx: NSManagedObjectContext = Persistence.shared.context) { self.ctx = ctx }

    func upsert(day: Date, prayer: PrayerName, status: PrayerStatus, inJamaah: Bool) {
        let d = day.startOfDay
        if let existing = fetch(day: d, prayer: prayer) {
            existing.statusEnum = status
            existing.inJamaah = inJamaah
        } else {
            let rec = PrayerRecord(context: ctx)
            rec.day = d
            rec.prayer = prayer.rawValue
            rec.statusEnum = status
            rec.inJamaah = inJamaah
        }
        try? ctx.save()
    }

    func fetch(day: Date, prayer: PrayerName) -> PrayerRecord? {
        let req = PrayerRecord.fetchRequest()
        req.predicate = NSPredicate(format: "day == %@ AND prayer == %@", day.startOfDay as CVarArg, prayer.rawValue)
        req.fetchLimit = 1
        return try? ctx.fetch(req).first
    }

    func fetchRange(from: Date, to: Date) -> [PrayerRecord] {
        let req = PrayerRecord.fetchRequest()
        req.predicate = NSPredicate(format: "day >= %@ AND day <= %@", from.startOfDay as CVarArg, to.startOfDay as CVarArg)
        return (try? ctx.fetch(req)) ?? []
    }

    func dailyMatrix(from: Date, to: Date) -> [Date: [PrayerName: PrayerRecord]] {
        let recs = fetchRange(from: from, to: to)
        var dict: [Date: [PrayerName: PrayerRecord]] = [:]
        for r in recs {
            let d = r.day.startOfDay
            dict[d, default: [:]][r.prayerName] = r
        }
        return dict
    }
}

// extension Date {
//    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
//    
//}
