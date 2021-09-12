//
//  ImportManager.swift
//  ImportManager
//
//  Created by Ethan Lipnik on 9/9/21.
//

import Foundation
import Combine
import CSV
import DomainParser
import AuthenticationServices

class ImportManager: ObservableObject {
    // MARK: - Variables
    @Published var importedAccounts: [ImportedAccount] = []
    @Published var addedAccounts: Set<Account> = []
    @Published var isImporting: Bool = false
    @Published var progress: Float = 0
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    var selectedVault: Vault?
    var fileFormat: FileFormat?
    let appFormat: AppFormat
    
    // MARK: - Types
    struct ImportedAccount: Identifiable, Hashable {
        let id: UUID = UUID()
        
        var name: String
        var url: String
        var username: String
        var password: String
        var otpAuth: String
    }
    
    // MARK: - Init
    init(vault: Vault? = nil, fileFormat: FileFormat? = nil, appFormat: AppFormat) {
        self.selectedVault = vault
        self.fileFormat = fileFormat
        self.appFormat = appFormat
    }
    
    func importFromFile(_ url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let fileExtension = url.pathExtension.lowercased()
            switch fileExtension {
            case "csv":
                fileFormat = .csv
                let stream = InputStream(url: url)!
                let csv = try! CSVReader(stream: stream, hasHeaderRow: true).lazy
                
                let importedAccounts = csv.map({ ImportedAccount(name: $0[0], url: $0[1], username: $0[2], password: $0[3], otpAuth: $0[safe: 4] ?? "") })
                
                DispatchQueue.main.async {
                    self.importedAccounts = importedAccounts.map({ $0 })
                }
                stream.close()
            case "json":
                fileFormat = .json
                fatalError()
            default:
                break
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> Void) {
        guard let selectedVault = selectedVault else {
            return
        }
        
        isImporting = true
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            do {
                let domainParser = try DomainParser()
                
                func finalize() {
                    if progress >= Float(importedAccounts.count) {
                        do {
                            try viewContext.save()
                            
                            // Save credentials for autofill
                            ASCredentialIdentityStore.shared.getState { state in
                                if state.isEnabled {
                                    
                                    let domainIdentifers = addedAccounts.map({ ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: $0.domain!, type: .domain),
                                                                                                            user: $0.username!,
                                                                                                            recordIdentifier: nil) })
                                    
                                    
                                    ASCredentialIdentityStore.shared.saveCredentialIdentities(domainIdentifers, completion: {(_,error) -> Void in
                                        print(error?.localizedDescription ?? "No errors in saving credentials")
                                    })
                                }
                            }
                            
                            completion(nil)
                        } catch {
                            completion(error)
                        }
                    }
                }
                
                for importedAccount in importedAccounts {
                    do {
                        if let url = URL(string: importedAccount.url), let host = url.host, let domain = domainParser.parse(host: host)?.domain?.lowercased(), !addedAccounts.contains(where: { $0.domain == domain && $0.username == importedAccount.username }) {
                            
                            let account = Account(context: viewContext)
                            account.domain = domain
                            account.url = url.absoluteString.removeHTTP.removeWWW
                            
                            account.username = importedAccount.username
                            account.otpAuth = importedAccount.otpAuth
                            account.dateAdded = Date()
                            
                            guard let encryptedPassword = try CryptoSecurityService.encrypt(importedAccount.password) else {
                                DispatchQueue.main.async {
                                    progress += 1
                                    finalize()
                                }
                                return
                            }
                            account.password = encryptedPassword
                            account.passwordLength = Int16(importedAccount.password.count)
                            
                            selectedVault.addToAccounts(account)
                            
                            DispatchQueue.main.async {
                                addedAccounts.insert(account)
                                progress += 1
                                
                                finalize()
                            }
                        } else {
                            DispatchQueue.main.async {
                                progress += 1
                                
                                finalize()
                            }
                        }
                    } catch {
                        print(importedAccount)
                        completion(error)
                    }
                }
            } catch {
                completion(error)
            }
        }
    }
}

enum FileFormat: String {
    case json
    case csv
}

enum AppFormat: String {
    case onePassword
    case bitwarden
    case browser
}
