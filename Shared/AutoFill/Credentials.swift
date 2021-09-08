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
                .filter({ $0.password != nil && $0.username != nil })
        } catch {
            print(error)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
     */
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        self.selectedCredential = credentialIdentity
    }
    
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
            fetchRequest.predicate = NSPredicate(format: "domain contains[c] %@", mainDomain)
            let fetchedResults = try viewContext.fetch(fetchRequest)
            
            self.accounts = fetchedResults
            
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
        self.selectedCredential = credentialIdentity
        
        guard let account = credentialIdentity.asAccount(allAccounts) else { extensionContext.cancelRequest(withError: ASExtensionError(.failed)); return }
        
        func decrypt() throws {
            let decryptedAccount = try decryptedAccount(account)
            let passwordCredential = ASPasswordCredential(user: decryptedAccount.username, password: decryptedAccount.password)
            
            extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        }
        
#if os(macOS)
        extensionContext.cancelRequest(withError: ASExtensionError(.userInteractionRequired))
#else
        do {
            try decrypt()
        } catch {
            extensionContext.cancelRequest(withError: ASExtensionError(.userInteractionRequired))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                try? decrypt()
            }
        }
#endif
    }
    
    func authorize() {
#if os(macOS)
        let password = textField.stringValue
#else
        let password = textField.text!
#endif
        let success = CryptoSecurityService.runEncryptionTest(password)
        
        guard success else {
            
#if os(macOS)
            textField.stringValue = ""
#else
            textField.text = ""
#endif
            
            return
        }
        
        isAuthorized = true
        
        if let selectedCredential = selectedCredential {
            guard let account = selectedCredential.asAccount(allAccounts),
                  let username = account.username,
                  let encryptedPassword = account.password,
                  let password = try? CryptoSecurityService.decrypt(encryptedPassword, encryptionKey: CryptoSecurityService.generateKey(fromString: password))
            else { extensionContext.cancelRequest(withError: ASExtensionError(.failed)); return }
            
            let passwordCredential = ASPasswordCredential(user: username, password: password)
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
            
            isAuthorized = false
        } else {
#if os(macOS)
            scrollView.isHidden = false
            lockView.isHidden = true
#else
            tableView.isHidden = false
            lockView.isHidden = true
#endif
            
            CryptoSecurityService.loadEncryptionKey(password)
        }
    }
}

extension ASPasswordCredentialIdentity {
    func asAccount(_ accounts: [Account]) -> Account? {
        return accounts.first(where: { $0.username == self.user && $0.domain == self.serviceIdentifier.identifier })
    }
}
