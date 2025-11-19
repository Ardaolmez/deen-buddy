//
//  Persistence.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import CoreData

enum Persistence {
    static let shared = PersistenceController()

    final class PersistenceController {
        let container: NSPersistentContainer

        init(inMemory: Bool = false) {
            // The name must match your .xcdatamodeld filename ("PrayerModel")
            container = NSPersistentContainer(name: "PrayerModel")
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores { _, error in
                if let error = error { fatalError("Unresolved error \(error)") }
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
        }

        var context: NSManagedObjectContext { container.viewContext }

        func saveIfNeeded() {
            let ctx = container.viewContext
            if ctx.hasChanges {
                try? ctx.save()
            }
        }
    }
}

