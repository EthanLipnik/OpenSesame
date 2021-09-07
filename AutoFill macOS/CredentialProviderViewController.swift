//
//  CredentialProviderViewController.swift
//  AutoFill macOS
//
//  Created by Ethan Lipnik on 8/19/21.
//

import AuthenticationServices

class CredentialProviderViewController: ASCredentialProviderViewController {
    
    let viewContext = PersistenceController.shared.container.viewContext
    var accounts: [Account] = []
    var allAccounts: [Account] = []
    
    lazy var selectedCredential: ASPasswordCredentialIdentity? = nil
    lazy var isAuthorized: Bool = false
    
    @IBOutlet weak var textField: NSSecureTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var lockView: NSStackView!
    
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
    
    @IBAction func cancelBtnClick(_ sender: Any) {
        isAuthorized = false
        self.extensionContext.cancelRequest(withError: ASExtensionError(.userCanceled))
    }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        authorize()
    }
    @IBAction func textFieldEnter(_ sender: Any) {
        authorize()
    }
}

extension CredentialProviderViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allAccounts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView
        
        let account = allAccounts[row]
        
        if tableColumn?.title == "Username" {
            cell?.textField?.stringValue = account.username ?? "Unknown username"
        } else if tableColumn?.title == "Website" {
            cell?.textField?.stringValue = account.domain ?? account.url ?? "Unknown website"
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let account = allAccounts[tableView.selectedRow]
        
        guard let username = account.username,
              let encryptedPassword = account.password,
              let password = try? CryptoSecurityService.decrypt(encryptedPassword)
        else { extensionContext.cancelRequest(withError: ASExtensionError(.failed)); print(account); return }
        
        let passwordCredential = ASPasswordCredential(user: username, password: password)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        
        isAuthorized = false
    }
}

fileprivate enum CellIdentifiers {
    static let AccountCell = "AccountCell"
  }
