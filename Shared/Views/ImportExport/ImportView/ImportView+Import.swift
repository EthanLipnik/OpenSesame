//
//  ImportView+Import.swift
//  ImportView+Import
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation
import AuthenticationServices
import DomainParser

extension ImportView {
    func importAccounts() {
        
        guard let selectedVault = vaults[safe: selectedVault] else {
            return
        }
        
        isImporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let domainParser = try DomainParser()
                
                func finalize() {
                    if self.accountProgress >= accounts.count {
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                        
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
                        
                        dismiss.callAsFunction()
                    }
                }
                
                for importedAccount in accounts {
                    do {
                        if let url = URL(string: importedAccount.url), let host = url.host, let domain = domainParser.parse(host: host)?.domain?.lowercased(), !addedAccounts.contains(where: { $0.domain == domain && $0.username == importedAccount.username }) {
                            
                            let account = Account(context: viewContext)
                            account.domain = domain
                            account.url = url.absoluteString
                            
                            account.username = importedAccount.username
                            account.otpAuth = importedAccount.otpAuth
                            account.dateAdded = Date()
                            
                            guard let encryptedPassword = try CryptoSecurityService.encrypt(importedAccount.password) else { return }
                            account.password = encryptedPassword
                            account.passwordLength = Int16(importedAccount.password.count)
                            
                            selectedVault.addToAccounts(account)
                            
                            DispatchQueue.main.async {
                                self.addedAccounts.append(account)
                                self.accountProgress += 1
                                
                                finalize()
                            }
                        } else {
                            self.accountProgress += 1
                            
                            finalize()
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
