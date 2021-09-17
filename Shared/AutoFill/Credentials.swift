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
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
     */
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        self.autoFillService.selectedCredential = credentialIdentity
    }
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        print("Preparing credentials")
        do {
            try autoFillService.loadAccountsForServiceIdentifiers(serviceIdentifiers)
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
#if !os(macOS)
        let authenticationPolicy: AuthenticationPolicy = .biometryCurrentSet
#else
        let authenticationPolicy: AuthenticationPolicy = [.biometryCurrentSet, .or, .watch]
#endif
        if let masterPassword = try OpenSesameKeychain()
            .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
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
        autoFillService.selectedCredential = credentialIdentity
        
        guard let account = credentialIdentity.asAccount(autoFillService.allAccounts) else { extensionContext.cancelRequest(withError: ASExtensionError(.failed)); return }
        
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
}

extension ASPasswordCredentialIdentity {
    func asAccount(_ accounts: [Account]) -> Account? {
        return accounts.first(where: { $0.username == self.user && $0.domain == self.serviceIdentifier.identifier })
    }
}
