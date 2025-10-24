//
//  DemoData.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import Foundation
import CoreData

/// ONE-FILE DEMO SEEDER
/// - Seeds Core Data with random prayer records for the last `daysBack` days
/// - Safe to call multiple times (only seeds if empty unless `force` is true)
enum DemoData {

    /// Seed the database with random-ish data.
    /// - Parameters:
    ///   - daysBack: how many days backwards to generate (default: 90)
    ///   - force: wipe then seed even if data exists (default: false)
    static func seed(daysBack: Int = 90, force: Bool = false) {
        let ctx = Persistence.shared.context

        if !force, hasAnyData(in: ctx) { return }

        if force {
            wipeAll(in: ctx)
        }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date()-1)

        for i in 0..<daysBack {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            for p in PrayerName.allCases {
                let rec = PrayerRecord(context: ctx)
                rec.day = day
                rec.prayer = p.rawValue

             //   let roll = Int.random(in: 0...99)
//                rec.statusEnum = roll < 65 ? .onTime : (roll < 85 ? .late : .notPrayed)
                rec.statusEnum = .onTime

                // Only mark Jumu'ah (jamaah) on Friday Dhuhr
                if p == .dhuhr, day.isFriday, rec.statusEnum != .notPrayed {
                    rec.inJamaah = true
                } else {
                    rec.inJamaah = false
                }
            }
        }
        
        do {
            try ctx.save()
            print("✅ DemoData: seeded \(daysBack) days × \(PrayerName.allCases.count) prayers")
        } catch {
            print("❌ DemoData save error:", error)
        }
    }

    /// Remove all PrayerRecord rows.
    static func wipe() {
        let ctx = Persistence.shared.context
        wipeAll(in: ctx)
    }

    // MARK: - Internals

    private static func hasAnyData(in ctx: NSManagedObjectContext) -> Bool {
        let req: NSFetchRequest<PrayerRecord> = PrayerRecord.fetchRequest()
        req.fetchLimit = 1
        let count = (try? ctx.count(for: req)) ?? 0
        return count > 0
    }

    private static func wipeAll(in ctx: NSManagedObjectContext) {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PrayerRecord")
        let del = NSBatchDeleteRequest(fetchRequest: fetch)
        _ = try? ctx.execute(del)
        try? ctx.save()
        print("🧹 DemoData: wiped all PrayerRecord rows")
    }
}
