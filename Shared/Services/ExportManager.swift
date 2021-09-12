//
//  ExportManager.swift
//  ExportManager
//
//  Created by Ethan Lipnik on 9/12/21.
//

import Foundation
import Combine
import CSV
import CoreData

class ExportManager: ObservableObject {
    // MARK: - Variables
    @Published var progress: Float = 0
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    var selectedVault: Vault?
    
    // MARK: - Init
    init(vault: Vault? = nil) {
        self.selectedVault = vault
    }
    
    func export(_ fileFormat: FileFormat, appFormat: AppFormat) throws -> ExportFile {
        let accountsFetch = NSFetchRequest<Account>(entityName: "Account")
        
        if let selectedVault = selectedVault {
            accountsFetch.predicate = NSPredicate(format: "vault == %@", selectedVault)
        }
        let accounts = try viewContext.fetch(accountsFetch)
        
        switch fileFormat {
        case .json:
            let formattedAccounts = try accounts.compactMap { account -> [String: String]? in
                guard let encryptedPassword = account.password else { return nil }
                let password = try CryptoSecurityService.decrypt(encryptedPassword)
                switch appFormat {
                case .browser:
                    return [
                        "Title": account.domain ?? "",
                        "URL": account.url ?? "",
                        "Username": account.username ?? "",
                        "Password": password ?? "",
                        "OTPAuth": account.otpAuth ?? ""
                    ]
                case .bitwarden:
                    return [
                        "folder": selectedVault?.name ?? "",
                        "favorite": account.isPinned ? "1" : "0",
                        "type": "login",
                        "name": account.domain ?? "",
                        "notes": account.notes ?? "",
                        "fields": "",
                        "login_uri": account.url ?? "",
                        "login_username": account.username ?? "",
                        "login_password": password ?? "",
                        "login_totp": account.otpAuth ?? ""
                    ]
                case .onePassword:
                    return [
                        "Notes": account.notes ?? "",
                        "Password": password ?? "",
                        "Title": account.domain ?? "",
                        "Type": "Login",
                        "URL": account.url ?? "",
                        "Username": account.username ?? "",
                        "OTPAuth": account.otpAuth ?? ""
                    ]
                }
            }
            
            let json = try JSONSerialization.data(withJSONObject: formattedAccounts, options: .prettyPrinted)
            guard let string = String(data: json, encoding: .utf8) else { throw CocoaError(.fileReadCorruptFile) }
            return ExportFile(string, format: fileFormat)
        case .csv:
            let csv = try CSVWriter(stream: .toMemory())
            
            // Write a row
            switch appFormat {
            case .browser:
                try csv.write(row: ["Title", "URL", "Username", "Password", "OTPAuth"])
                try accounts.forEach({ account in
                    guard let encryptedPassword = account.password else { return }
                    let password = try CryptoSecurityService.decrypt(encryptedPassword)
                    
                    csv.beginNewRow()
                    
                    try csv.write(row: [
                        account.domain ?? "",
                        account.url ?? "",
                        account.username ?? "",
                        password ?? "",
                        account.otpAuth ?? ""
                    ])
                })
            case .onePassword:
                try csv.write(row: ["Notes", "Password", "Title", "Type", "URL", "Username", "OTPAuth"])
                try accounts.forEach({ account in
                    guard let encryptedPassword = account.password else { return }
                    let password = try CryptoSecurityService.decrypt(encryptedPassword)
                    
                    csv.beginNewRow()
                    
                    try csv.write(row: [
                        account.notes ?? "",
                        password ?? "",
                        account.domain ?? "",
                        "Login",
                        account.url ?? "",
                        account.username ?? ""
                    ])
                })
            case .bitwarden:
                try csv.write(row: ["folder", "favorite", "type", "name", "notes", "fields", "login_uri", "login_username", "login_password", "login_totp"])
                
                try accounts.forEach({ account in
                    guard let encryptedPassword = account.password else { return }
                    let password = try CryptoSecurityService.decrypt(encryptedPassword)
                    
                    csv.beginNewRow()
                    
                    try csv.write(row: [
                        selectedVault?.name ?? "",
                        account.isPinned ? "1" : "0",
                        "login",
                        account.domain ?? "",
                        account.notes ?? "",
                        "",
                        account.url ?? "",
                        account.username ?? "",
                        password ?? "",
                        account.otpAuth ?? ""
                    ])
                })
            }

            csv.stream.close()

            // Get a String
            guard let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data,
                  let csvString = String(data: csvData, encoding: .utf8) else { throw CocoaError(.fileReadCorruptFile) }
            return ExportFile(csvString, format: fileFormat)
        }
    }
}
