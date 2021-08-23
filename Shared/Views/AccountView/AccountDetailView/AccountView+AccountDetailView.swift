//
//  AccountView+AccountDetailView.swift
//  AccountView+AccountDetailView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension AccountView {
    struct AccountDetailsView: View {
        // MARK: - Environment
        @Environment(\.managedObjectContext) var viewContext
        
        // MARK: - Variables
        @StateObject var otpService: OTPAuthenticatorService
        
        @State var account: Account
        @Binding var isEditing: Bool
        
        @State var isShowingPassword: Bool = false
        
        @State var newUsername: String = ""
        @State var newPassword: String = ""
        
        @State var decryptedPassword: String? = nil
        
        @State var isAddingVerificationCode: Bool = false
        @State var newVerificationURL: String = ""
        
        @State var displayedPassword: String = ""
        
        // MARK: - Init
        init(account: Account, isEditing: Binding<Bool>) {
            self.account = account
            self._isEditing = isEditing
            
            if !(account.otpAuth?.isEmpty ?? true) {
                if let url = URL(string: account.otpAuth ?? ""), url.isValidURL {
                    _otpService = StateObject(wrappedValue: OTPAuthenticatorService(url))
                } else {
                    _otpService = StateObject(wrappedValue: OTPAuthenticatorService(account.otpAuth ?? ""))
                }
            } else {
                _otpService = StateObject(wrappedValue: OTPAuthenticatorService())
            }
        }
        
        // MARK: - View
        var body: some View {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    emailView
                    
                    passwordView
                    
                    otpView
                }
                .padding(5)
                .onChange(of: isEditing) { isEditing in
                    if isEditing {
                        do {
                            decryptedPassword = try CryptoSecurityService.decrypt(account.password!, tag: account.encryptionTag!, nonce: account.nonce)
                            newUsername = account.username ?? ""
                            newPassword = decryptedPassword ?? ""
                        } catch {
                            print(error)
                        }
                    } else {
                        do {
                            account.username = newUsername
                            
                            let encryptedPassword = try CryptoSecurityService.encrypt(newPassword)
                            account.passwordLength = Int16(newPassword.count)
                            account.password = encryptedPassword?.value ?? account.password
                            account.encryptionTag = encryptedPassword?.tag ?? account.encryptionTag
                            account.nonce = CryptoSecurityService.nonceStr
                            
                            account.lastModified = Date()
                            
                            try? viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
                .onAppear {
                    displayedPassword = CryptoSecurityService.randomString(length: Int(account.passwordLength))
                }
            }
        }
    }
}
