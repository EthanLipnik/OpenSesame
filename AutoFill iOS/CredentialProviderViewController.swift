//
//  CredentialProviderViewController.swift
//  AutoFill iOS
//
//  Created by Ethan Lipnik on 8/18/21.
//

import AuthenticationServices
import DomainParser
import KeychainAccess

class CredentialProviderViewController: ASCredentialProviderViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewContext = PersistenceController.shared.container.viewContext
    var accounts: [Account] = []
    var allAccounts: [Account] = []
    
    lazy var selectedCredential: ASPasswordCredentialIdentity? = nil
    lazy var isAuthorized: Bool = false
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var lockView: UIStackView!
    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.
     
     override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
     let databaseIsUnlocked = true
     if (databaseIsUnlocked) {
     let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
     self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
     } else {
     self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
     }
     }
     */
    
    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.
     
     override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
     }
     */
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    @IBAction func loginBtn(_ sender: Any) {
        authorize()
    }
    @IBAction func textFieldEnter(_ sender: Any) {
        authorize()
    }
}

extension CredentialProviderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "All Accounts"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return accounts.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && !accounts.isEmpty {
            return accounts.count
        } else {
            return allAccounts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var account: Account!
        if indexPath.section == 0 && !accounts.isEmpty {
            account = accounts[indexPath.item]
        } else {
            account = allAccounts[indexPath.item]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = account.domain
        cell.detailTextLabel?.text = account.username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var account: Account!
        if indexPath.section == 0 && !accounts.isEmpty {
            account = accounts[indexPath.item]
        } else {
            account = allAccounts[indexPath.item]
        }
        
        do {
            let decryptedAccount = try decryptedAccount(account)
            let passwordCredential = ASPasswordCredential(user: decryptedAccount.username, password: decryptedAccount.password)
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } catch {
            self.extensionContext.cancelRequest(withError: error)
        }
        
        isAuthorized = false
    }
}
