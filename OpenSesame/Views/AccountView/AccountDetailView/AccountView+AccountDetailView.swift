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

        @Environment(\.managedObjectContext)
        var viewContext

        // MARK: - Variables

        @StateObject
        var otpService: OTPAuthenticatorService

        @State
        var account: Account
        @Binding
        var isEditing: Bool

        @Binding
        var isAddingVerificationCode: Bool
        @State
        var isScanningQRCode: Bool = false

        @State
        var isShowingPassword: Bool = false

        @State
        var newUsername: String = ""
        @State
        var newPassword: String = ""

        @State
        var decryptedPassword: String?
        @State
        var newVerificationURL: String = ""

        @State
        var displayedPassword: String = ""

        // MARK: - Init

        init(account: Account, isEditing: Binding<Bool>, isAddingVerificationCode: Binding<Bool>) {
            self.account = account
            _isEditing = isEditing
            _isAddingVerificationCode = isAddingVerificationCode

            if !(account.otpAuth?.isEmpty ?? true) {
                if let url = URL(string: account.otpAuth ?? ""), url.isValidURL {
                    _otpService = StateObject(wrappedValue: OTPAuthenticatorService(url))
                } else {
                    _otpService =
                        StateObject(wrappedValue: OTPAuthenticatorService(account.otpAuth ?? ""))
                }
            } else {
                _otpService = StateObject(wrappedValue: OTPAuthenticatorService())
            }
        }

        // MARK: - View

        var body: some View {
            GroupBox {
                VStack(alignment: .leading, spacing: 25) {
                    emailView

                    passwordView

                    otpView
                }
                .padding(5)
                .onChange(of: isEditing) { isEditing in
                    if isEditing {
                        do {
                            decryptedPassword = try CryptoSecurityService.decrypt(account.password!)
                            newUsername = account.username ?? ""
                            newPassword = decryptedPassword ?? ""
                        } catch {
                            print(error)
                        }
                    } else {
                        withAnimation {
                            isAddingVerificationCode = false
                        }

                        do {
                            account.username = newUsername

                            let encryptedPassword = try CryptoSecurityService.encrypt(newPassword)
                            account.passwordLength = Int16(newPassword.count)
                            account.password = encryptedPassword

                            account.lastModified = Date()

                            try? viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
                .onAppear {
                    displayedPassword = CryptoSecurityService
                        .randomString(length: Int(account.passwordLength))!
                }
            }
        }
    }
}
