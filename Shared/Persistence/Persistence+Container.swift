//
//  Persistence+Container.swift
//  Persistence+Container
//
//  Created by Ethan Lipnik on 9/6/21.
//

import Foundation
import CoreData
import CloudKit

extension NSPersistentContainer {
    static func create(withSync iCloudSync: Bool = UserSettings.default.shouldSyncWithiCloud) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "OpenSesame")
        
        let privateStoreDescription = NSPersistentStoreDescription(url: PersistenceController.storeURL)
        privateStoreDescription.shouldMigrateStoreAutomatically = true
        privateStoreDescription.shouldInferMappingModelAutomatically = true
        
        let sharedStoreURL = URL.storeURL(for: OpenSesameConfig.APP_GROUP, databaseName: OpenSesameConfig.APP_GROUP + "-shared")
        let sharedStoreDescription: NSPersistentStoreDescription = privateStoreDescription.copy() as! NSPersistentStoreDescription
        sharedStoreDescription.url = sharedStoreURL
        
        if iCloudSync {
            let containerIdentifier = "iCloud.\(OpenSesameConfig.PRODUCT_BUNDLE_IDENTIFIER_BASE)"
            
            let privateCloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateCloudKitOptions.databaseScope = .private
            privateStoreDescription.cloudKitContainerOptions = privateCloudKitOptions
            
            let sharedCloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            sharedCloudKitOptions.databaseScope = .shared
            sharedStoreDescription.cloudKitContainerOptions = sharedCloudKitOptions
        } else {
            privateStoreDescription.cloudKitContainerOptions = nil
        }
        
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        privateStoreDescription.setOption(true as NSNumber,
                                          forKey: remoteChangeKey)
        
        privateStoreDescription.setOption(true as NSNumber,
                                          forKey: NSPersistentHistoryTrackingKey)
        
        container.persistentStoreDescriptions = [privateStoreDescription, sharedStoreDescription]
        
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
