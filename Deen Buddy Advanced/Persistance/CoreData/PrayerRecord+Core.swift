//
//  PrayerRecord+Core.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import CoreData
//
@objc(PrayerRecord)
public class PrayerRecord: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrayerRecord> {
        NSFetchRequest<PrayerRecord>(entityName: "PrayerRecord")
    }

    @NSManaged public var day: Date
    @NSManaged public var prayer: String
    @NSManaged public var status: Int16
    @NSManaged public var inJamaah: Bool
}

extension PrayerRecord {
    var prayerName: PrayerName { PrayerName(rawValue: prayer)! }
    var statusEnum: PrayerStatus {
        get { PrayerStatus(rawValue: status) ?? .notPrayed }
        set { status = newValue.rawValue }
        
    }
}


//import CoreData
//
//extension PrayerRecord {
//    var prayerName: PrayerName {
//        PrayerName(rawValue: prayer) ?? .fajr
//    }
//
//    var statusEnum: PrayerStatus {
//        get { PrayerStatus(rawValue: status) ?? .notPrayed }
//        set { status = newValue.rawValue }
//    }
//}
