//
//  Persistence.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Foundation
import CoreData
import KeychainAccess
import AuthenticationServices

class PersistenceController {
    static let shared = PersistenceController()
    
    static let storeURL = URL.storeURL(for: OpenSesameConfig.APP_GROUP,
                                          databaseName: OpenSesameConfig.APP_GROUP)

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

    var container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        
        if !PersistenceController.isICloudContainerAvailable() {
            UserDefaults.group.set(true, forKey: "shouldNotSyncWithiCloud")
        }
        
        container = NSPersistentContainer.create(inMemory: inMemory)
        
        let coreDataVersion = UserDefaults.group.float(forKey: "coreDataVersion")
        if coreDataVersion < 1.3 {
            try? FileManager.default.removeItem(at: PersistenceController.storeURL)
            
            UserDefaults(suiteName: OpenSesameConfig.APP_GROUP)?.set(1.3, forKey: "coreDataVersion")
            
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
        
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
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
                do {
                    try viewContext.setQueryGenerationFrom(.current)
                    
                    let vaultsFetch = NSFetchRequest<Vault>(entityName: "Vault")
                    let vaults = try viewContext.fetch(vaultsFetch)
                    if vaults.isEmpty {
                        let vault = Vault(context: viewContext)
                        vault.name = "Primary"
                        
                        try viewContext.save()
                    }
                    
                    try? self?.addMissingAccountsToPrimaryVault(viewContext: viewContext)
                    self?.updateCredentials(viewContext: viewContext)
                } catch {
                    print(error)
                }
            }
        })
    }
    
    func updateCredentials(viewContext: NSManagedObjectContext) {
        ASCredentialIdentityStore.shared.getState { state in
            if state.isEnabled {
                ASCredentialIdentityStore.shared.removeAllCredentialIdentities { success, error in
                    let accountsFetch = NSFetchRequest<Account>(entityName: "Account")
                    
                    do {
                        let accounts = try viewContext.fetch(accountsFetch)
                        let domainIdentifers = accounts.map({ ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: $0.domain!, type: .domain),
                                                                                           user: $0.username!,
                                                                                           recordIdentifier: nil) })
                        
                        
                        ASCredentialIdentityStore.shared.saveCredentialIdentities(domainIdentifers, completion: {(_,error) -> Void in
                            print(error?.localizedDescription ?? "No errors in saving credentials")
                        })
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func addMissingAccountsToPrimaryVault(viewContext: NSManagedObjectContext) throws {
        let vaultsFetch = NSFetchRequest<Vault>(entityName: "Vault")
        vaultsFetch.predicate = NSPredicate(format: "name == %@", "Primary")
        let vaults = try viewContext.fetch(vaultsFetch)
        guard let vault = vaults.first else { return }
        
        let accountsFetch = NSFetchRequest<Account>(entityName: "Account")
        accountsFetch.predicate = NSPredicate(format: "vault == nil")
        let accounts = try viewContext.fetch(accountsFetch)
        accounts.forEach({ vault.addToAccounts($0) })
        
        try viewContext.save()
    }
    
    func uploadStoreTo(_ service: CloudService) throws {
        switch service {
        case .iCloud:
            if let iCloudContainer = PersistenceController.containerUrl {
                let destinationURL = iCloudContainer.appendingPathComponent("\(OpenSesameConfig.APP_GROUP).sqlite")
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                let backup = URL.storeURL(for: OpenSesameConfig.APP_GROUP, databaseName: "backup")
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
    
    static func isICloudContainerAvailable()->Bool {
        return FileManager.default.ubiquityIdentityToken != nil
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
