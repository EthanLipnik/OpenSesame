//
//  Credentials.swift
//  Credentials
//
//  Created by Ethan Lipnik on 8/19/21.
//

import CoreData
import AuthenticationServices
import DomainParser
import KeychainAccess

extension CredentialProviderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let fetchRequest : NSFetchRequest<Account> = Account.fetchRequest()
            let fetchedResults = try viewContext.fetch(fetchRequest)
            
            self.allAccounts = fetchedResults
        } catch {
            print(error)
        }
        
#if os(iOS)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
#endif
    }
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        print("Preparing credentials")
        do {
            let domainParse = try DomainParser()
            
            let hosts = serviceIdentifiers
                .compactMap({ URL(string: $0.identifier)?.host })
            let domains = hosts
                .compactMap({ domainParse.parse(host: $0)?.domain?.lowercased() })
            guard let mainDomain = domains.first else { return }
            
            let fetchRequest : NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "website contains[c] %@", mainDomain)
            let fetchedResults = try viewContext.fetch(fetchRequest)
            
            self.accounts = fetchedResults
            
            print("Accounts", accounts)
            
#if os(iOS)
            tableView.reloadData()
#endif
        } catch {
            print(error)
        }
    }
    
    func decryptedAccount(_ account: Account) throws -> (username: String, password: String) {
#if targetEnvironment(simulator)
        let accessibility: Accessibility = .always
#else
        let accessibility: Accessibility = .whenUnlockedThisDeviceOnly
#endif
        if let masterPassword = try Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
            .accessibility(accessibility, authenticationPolicy: .biometryCurrentSet)
            .authenticationPrompt("Authenticate to login to view your accounts")
            .get("masterPassword") {
            
            CryptoSecurityService.loadEncryptionKey(masterPassword)
            
            let decryptPassword = try CryptoSecurityService.decrypt(account.password!)
            
            print("Returned decrypted account")
            
            return (account.username!, decryptPassword!)
        } else {
            print("No master password")
            
            throw CocoaError(.coderValueNotFound)
        }
    }
    
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        
        guard let account = allAccounts.first(where: { $0.username == credentialIdentity.user && $0.domain == credentialIdentity.serviceIdentifier.identifier }) else { extensionContext.cancelRequest(withError: CocoaError(.coderValueNotFound)); fatalError() }
        
        do {
            let decryptedAccount = try decryptedAccount(account)
            let passwordCredential = ASPasswordCredential(user: decryptedAccount.username, password: decryptedAccount.password)
            
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } catch {
            extensionContext.cancelRequest(withError: error)
        }
    }
}
