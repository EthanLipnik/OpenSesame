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
    
    @State var didBiometricsFail: Bool = false
    
    @State var encryptionTestDoesntExist = false
    @State var encryptionTest: Data? = nil
    
    @State var isAuthenticating: Bool = false
    @State var needsToResetPassword: Bool = false
    
    @StateObject var userSettings = UserSettings.default
    
    @FocusState var isTextFieldFocussed: Bool
    
    @State private var isShowingBoardingScreen: Bool = !UserDefaults.standard.bool(forKey: "didShowBoardingScreen")
    @AppStorage("didShowBoardingScreen") var didShowBoardingScreen: Bool = false
    
    @State private var shouldShowCreatePassword: Bool = false
    
    
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
                .frame(maxWidth: 250, maxHeight: 250)
                .minimumScaleFactor(0.7)
                .animation(.default, value: isLocked)
            textField
                .blur(radius: isAuthenticating ? 2.5 : 0)
            Spacer()
        }
        .padding()
#if os(macOS) && !EXTENSION
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
#endif
        .allowsHitTesting(!isAuthenticating)
        .animation(.default, value: isAuthenticating)
        .padding()
        .navigationTitle("OpenSesame")
        
#if !EXTENSION
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
                let keychain = OpenSesameKeychain()
                
                try! keychain
                    .synchronizable(false)
                    .remove("masterPassword")
                try! keychain
                    .synchronizable(true)
                    .remove("encryptionTest")
                
                encryptionTest = nil
                encryptionTestDoesntExist = true
                
                shouldShowCreatePassword = true
            }
            Button("Cancel", role: .cancel) {
                needsToResetPassword = false
            }.keyboardShortcut(.cancelAction)
        }, message: {
            Text("You can change it but you won't be able to decrypt any of your accounts.")
        })
        .sheet(isPresented: $isShowingBoardingScreen) {
            BoardingView(encryptionTestDoesntExist: $encryptionTestDoesntExist, masterPasswordCompletion: createMasterPassword)
                .environment(\.managedObjectContext, viewContext)
#if os(iOS)
                .interactiveDismissDisabled()
#endif
        }
        .sheet(isPresented: $shouldShowCreatePassword) {
            CreatePasswordView(completionAction: createMasterPassword)
        }
        .onChange(of: didShowBoardingScreen) { newValue in
            if newValue {
                isShowingBoardingScreen = false
            }
        }
#endif
        .onAppear {
            //            let keychain = OpenSesameKeychain()
            //
            //            try! keychain
            //                .synchronizable(false)
            //                .remove("masterPassword")
            //            try! keychain
            //                .synchronizable(true)
            //                .remove("encryptionTest")
            //
            //            encryptionTest = nil
            //            encryptionTestDoesntExist = true
            //            didShowBoardingScreen = false
            //            isShowingBoardingScreen = true
            
            loadEncryptionTest()
#if !EXTENSION
            shouldShowCreatePassword = encryptionTest == nil && !isShowingBoardingScreen
#endif
            
            if !isLocked {
                isTextFieldFocussed = false
            } else if !(isShowingBoardingScreen || shouldShowCreatePassword || didShowBoardingScreen) {
                if userSettings.shouldUseBiometrics {
                    
    #if EXTENSION
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        unlockWithBiometrics()
                    }
    #else
                    unlockWithBiometrics()
    #endif
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isTextFieldFocussed = true
                    }
                }
            }
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView(isLocked: .constant(true)) {
            
        }
    }
}
