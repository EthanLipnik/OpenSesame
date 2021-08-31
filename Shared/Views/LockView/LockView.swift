//
//  LockView.swift
//  LockView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import KeychainAccess
import CloudKit

struct LockView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Variables
    @Binding var isLocked: Bool
    let onSuccessfulUnlock: () -> Void
    
    
    @State var password: String = ""
    @State var attempts: Int = 0
    
    @State var canAuthenticateWithBiometrics: Bool = true
    @State var biometricsFailed: Bool = false
    
    @State var encryptionTestDoesntExist = false
    @State var encryptionTest: Data? = nil
    
    @State var isAuthenticating: Bool = false
    @State var needsToResetPassword: Bool = false
    
    @StateObject var userSettings = UserSettings.default
    
    
    // MARK: - Variable Types
    public enum UnlockMethod {
        case biometrics
        case password
    }
    
    let biometricTypes: [UserAuthenticationService.BiometricType]
    
    init(isLocked: Binding<Bool>, onSuccessfulUnlock: @escaping () -> Void) {
        self._isLocked = isLocked
        self.onSuccessfulUnlock = onSuccessfulUnlock
        
        self.biometricTypes = UserAuthenticationService.availableBiometrics()
    }
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image("\(userSettings.selectedIcon)Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .animation(.default, value: isLocked)
            textField
            .blur(radius: isAuthenticating ? 2.5 : 0)
            Spacer()
        }
        .padding()
#if os(macOS)
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
#endif
        .allowsHitTesting(!isAuthenticating)
        .animation(.default, value: isAuthenticating)
        .padding()
        .navigationTitle("OpenSesame")
        
#if os(macOS)
        .toolbar { // LockView only toolbar
            ToolbarItem(placement: .primaryAction) {
                if isLocked {
                    Button {
                        needsToResetPassword.toggle()
                    } label: {
                        Label("Info", systemImage: "info")
                    }
                }
            }
        }
#else
        .overlay(Button(action: {
            needsToResetPassword.toggle()
        }, label: {
            Image(systemName: "info")
        }).padding(), alignment: .topTrailing)
#endif
        .alert("Forgot your password?", isPresented: $needsToResetPassword, actions: {
            Button("Reset password", role: .destructive) {
                let keychain = Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
                    .synchronizable(true)
                
                try! keychain
                    .remove("masterPassword")
                try! keychain
                    .remove("encryptionTest")
                
                encryptionTest = nil
                encryptionTestDoesntExist = true
            }
            Button("Cancel", role: .cancel) {
                needsToResetPassword = false
            }.keyboardShortcut(.cancelAction)
        }, message: {
            Text("You can change it but you won't be able to decrypt any of your accounts.")
        })
        
        // MARK: - Master Password Creation
        .sheet(isPresented: $encryptionTestDoesntExist) {
            CreatePasswordView(completionAction: createMasterPassword)
        }
        .onAppear {
            loadEncryptionTest()
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView(isLocked: .constant(true)) {
            
        }
    }
}
