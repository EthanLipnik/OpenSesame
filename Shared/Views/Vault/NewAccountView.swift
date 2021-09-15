//
//  NewAccountView.swift
//  NewAccountView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import AuthenticationServices
import KeychainAccess
import DomainParser

struct NewAccountView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Variables
    @State private var website: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    let selectedVault: Vault
    
    // MARK: - View
    var body: some View {
        VStack {
//            Text("New Account")
//                .font(.title.bold())
//                .frame(maxWidth: .infinity)
//                .padding([.top, .horizontal])
            GroupBox {
                VStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Label("Website or Name", systemImage: "globe")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Website or Name", text: $website)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.none)
                            .textContentType(.URL)
#endif
                            .disableAutocorrection(true)
                    }
                    VStack(alignment: .leading) {
                        Label("Email or Username", systemImage: "person.fill")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Email or Username", text: $username)
                            .textFieldStyle(.roundedBorder)
#if os(iOS)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
#else
                            .textContentType(.username)
#endif
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("Password", systemImage: "key.fill")
                            .foregroundColor(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                SecureField("Password", text: $password)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
#if os(iOS)
                                    .autocapitalization(.none)
                                    .textContentType(.newPassword)
#endif
                                    .disableAutocorrection(true)
                                Text(password.isEmpty ? " " : password)
                                    .font(.system(.body, design: .monospaced))
                            }
#if os(iOS)
                            Button {
                                password = Keychain.generatePassword()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .imageScale(.large)
                            }
#endif
                        }
                    }
                }
#if os(macOS)
                .padding(5)
#endif
            }
            .padding([.top, .horizontal])
            Spacer()
            HStack {
                Button("Cancel") {
                    dismiss.callAsFunction()
                }
                .keyboardShortcut(.cancelAction)
#if os(iOS)
                .hoverEffect()
#endif
                
                Spacer()
                Button("Add", action: add)
                    .keyboardShortcut(.defaultAction)
                    .disabled(website.isEmpty || username.isEmpty || password.isEmpty)
#if os(iOS)
                .hoverEffect()
#endif
            }.padding()
        }
#if os(macOS)
        .frame(width: 300)
#endif
    }
    
    
    // MARK: - Functions
    private func add() {
        do {
            let encryptedPassword = try CryptoSecurityService.encrypt(password)
            print("Encrypted password")
            
            let domainParser = try DomainParser()
            let domain = domainParser.parse(host: URL(string: website)?.host ?? website)?.domain
            
            let newAccount = Account(context: viewContext)
            newAccount.dateAdded = Date()
            
            newAccount.passwordLength = Int16(password.count)
            newAccount.password = encryptedPassword
            
            newAccount.domain = domain ?? website
            newAccount.url = website
            newAccount.username = username
            
            selectedVault.addToAccounts(newAccount)
            
            try viewContext.save()
            
            ASCredentialIdentityStore.shared.getState { state in
                if state.isEnabled {
                    
                    let domainIdentifer = ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: website, type: .domain),
                                                                       user: username,
                                                                       recordIdentifier: nil)
                    
                    
                    ASCredentialIdentityStore.shared.saveCredentialIdentities([domainIdentifer], completion: {(_,error) -> Void in
                        print(error?.localizedDescription ?? "No errors in saving credentials")
                    })
                }
            }
            
            dismiss.callAsFunction()
        } catch {
            print(error)
            
#if os(macOS)
            NSAlert(error: error).runModal()
#endif
        }
    }
}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView(selectedVault: .init())
    }
}
