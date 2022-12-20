//
//  Persistence+Container.swift
//  Persistence+Container
//
//  Created by Ethan Lipnik on 9/6/21.
//

import CoreData
import Foundation

extension NSPersistentContainer {
    static func create(withSync iCloudSync: Bool = UserSettings.default.shouldSyncWithiCloud) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "OpenSesame")

        let storeDescription = NSPersistentStoreDescription(url: PersistenceController.storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true

        if iCloudSync {
            let cloudkitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.\(OpenSesameConfig.PRODUCT_BUNDLE_IDENTIFIER_BASE)")
            storeDescription.cloudKitContainerOptions = cloudkitOptions
        } else {
            storeDescription.cloudKitContainerOptions = nil
        }

        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        storeDescription.setOption(true as NSNumber,
                                   forKey: remoteChangeKey)

        storeDescription.setOption(true as NSNumber,
                                   forKey: NSPersistentHistoryTrackingKey)

        container.persistentStoreDescriptions = [storeDescription]

        NSLog("🟢 Initialized CoreData container\(iCloudSync ? " with iCloud Sync" : "") at path: \(PersistenceController.storeURL.path)")

        return container
    }

    static func create(inMemory: Bool) -> NSPersistentCloudKitContainer {
        guard inMemory else { return .create() }

        let container = NSPersistentCloudKitContainer(name: "OpenSesame")

        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")

        return container
    }
}
