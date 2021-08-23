//
//  Persistence.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static let storeURL = URL.storeURL(for: "group.OpenSesame.ethanlipnik", databaseName: "group.OpenSesame.ethanlipnik")

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "OpenSesame")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeDescription = NSPersistentStoreDescription(url: PersistenceController.storeURL)
            
            let cloudkitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.ethanlipnik.OpenSesame")
            storeDescription.cloudKitContainerOptions = cloudkitOptions
            
            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            storeDescription.setOption(true as NSNumber,
                                       forKey: remoteChangeKey)
            
            storeDescription.setOption(true as NSNumber,
                                       forKey: NSPersistentHistoryTrackingKey)
            
#if !os(macOS)
            storeDescription.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
#endif
            
            container.persistentStoreDescriptions = [storeDescription]
            
            print("CoreData location", PersistenceController.storeURL.path)
        }
        let viewContext = container.viewContext
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                viewContext.automaticallyMergesChangesFromParent = true
                
                try? viewContext.setQueryGenerationFrom(.current)
            }
        })
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
