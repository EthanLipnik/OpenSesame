//
//  Persistence.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Foundation
import CoreData
import KeychainAccess

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
    
    static var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)
    }

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "OpenSesame")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeDescription = NSPersistentStoreDescription(url: PersistenceController.storeURL)
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true

            let cloudkitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.ethanlipnik.OpenSesame")
            storeDescription.cloudKitContainerOptions = cloudkitOptions

            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            storeDescription.setOption(true as NSNumber,
                                       forKey: remoteChangeKey)

            storeDescription.setOption(true as NSNumber,
                                       forKey: NSPersistentHistoryTrackingKey)

            container.persistentStoreDescriptions = [storeDescription]
            
            print("CoreData location", PersistenceController.storeURL.path)
        }
        
        if let coreDataVersion = UserDefaults(suiteName: "group.OpenSesame.ethanlipnik")?.float(forKey: "coreDataVersion"), coreDataVersion < 1.2 {
            try? FileManager.default.removeItem(at: PersistenceController.storeURL)
            
            UserDefaults(suiteName: "group.OpenSesame.ethanlipnik")?.set(1.2, forKey: "coreDataVersion")
            
            do {
                try self.downloadStoreFrom(.iCloud)
            } catch {
                print(error)
            }
        }
        
        loadStore()
        
        // Check if iCloud Drive folder exists, if not, create one.
        if let url = PersistenceController.containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        print("iCloud Drive folder location", PersistenceController.containerUrl?.path as Any)
    }
    
    func loadStore() {
        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        viewContext.automaticallyMergesChangesFromParent = true
        
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
                try? viewContext.setQueryGenerationFrom(.current)
            }
        })
    }
    
    func uploadStoreTo(_ service: CloudService) throws {
        switch service {
        case .iCloud:
            if let iCloudContainer = PersistenceController.containerUrl {
                let destinationURL = iCloudContainer.appendingPathComponent("group.OpenSesame.ethanlipnik.sqlite")
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                let backup = URL.storeURL(for: "group.OpenSesame.ethanlipnik", databaseName: "backup")
                print(iCloudContainer.path, backup.path)
                
                if FileManager.default.fileExists(atPath: backup.path) {
                    try FileManager.default.removeItem(at: backup)
                }
                
                try FileManager.default.copyItem(at: PersistenceController.storeURL, to: backup)
                try FileManager.default.setUbiquitous(true, itemAt: backup, destinationURL: destinationURL)
                
                print("Uploaded store to iCloud", iCloudContainer.path)
            } else {
                throw CocoaError(.fileNoSuchFile)
            }
        }
    }
    
    func downloadStoreFrom(_ service: CloudService) throws {
        switch service {
        case .iCloud:
            if let iCloudContainer = PersistenceController.containerUrl {
                
                let allContainers = try FileManager.default.contentsOfDirectory(atPath: iCloudContainer.path)
                let containersToDownload = allContainers
                    .filter({ $0.contains(".icloud") })
                let containers = containersToDownload.map({ iCloudContainer.appendingPathComponent($0) })
                containers.forEach({ let _ = $0.startAccessingSecurityScopedResource() })
                try containers.forEach({ try FileManager.default.startDownloadingUbiquitousItem(at: $0) })
                
                print(allContainers)
                if FileManager.default.fileExists(atPath: PersistenceController.storeURL.path) {
                    try FileManager.default.removeItem(at: PersistenceController.storeURL)
                }
                try FileManager.default.copyItem(at: iCloudContainer.appendingPathComponent("backup.sqlite"), to: PersistenceController.storeURL)
                
                loadStore()
            }
        }
    }
    
    enum CloudService {
        case iCloud
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
