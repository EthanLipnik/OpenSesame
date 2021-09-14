//
//  LockView+Functions.swift
//  LockView+Functions
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation
import KeychainAccess

extension LockView {
    // Try to load encryption test from Keychain Access.
    func loadEncryptionTest() {
        if let test = try? OpenSesameKeychain()
            .synchronizable(true)
            .getData("encryptionTest") {
            
            self.encryptionTest = test
        } else {
            encryptionTestDoesntExist = true
        }
    }
    
    static func encryptionTestExists() -> Bool {
        return (try? OpenSesameKeychain()
            .synchronizable(true)
            .contains("encryptionTest")) ?? false
    }
    
    // If a master password doesn't exist, then create one with a given password.
    func createMasterPassword(_ password: String) {
        CryptoSecurityService.loadEncryptionKey(password) {
            do {
                guard let randomString = CryptoSecurityService.randomString(length: 32, method: .cryptic), let test = try CryptoSecurityService.encrypt(randomString) else { fatalError() }
                
                self.encryptionTest = test
                try? OpenSesameKeychain()
                    .synchronizable(true)
                    .set(test, key: "encryptionTest")
                
                encryptionTestDoesntExist = false
                try? LockView.updateBiometrics(password) // Try to update biometrics if available.
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // Save the master password to Keychain Access with a limited accessibility and requiring biometrics to view.
    static func updateBiometrics(_ password: String) throws {
        let accessibility: Accessibility = .whenUnlockedThisDeviceOnly
#if !os(macOS)
        let authenticationPolicy: AuthenticationPolicy = .biometryCurrentSet
#else
        let authenticationPolicy: AuthenticationPolicy = [.biometryCurrentSet, .or, .watch]
#endif
        try OpenSesameKeychain()
            .accessibility(accessibility, authenticationPolicy: authenticationPolicy) // If the biometrics change, this will no longer be accessible.
            .authenticationPrompt("Authenticate to view your accounts")
            .set(password, key: "masterPassword")
        
        print("Updated biometrics for password", password)
    }
    
    // Test the given password with the saved encryption test to verify it is valid and correct.
    func unlock(_ password: String, method: UnlockMethod = .password) {
        guard let test = encryptionTest else { encryptionTestDoesntExist = true; return }
        
        CryptoSecurityService.loadEncryptionKey(password) {
            let string = try? CryptoSecurityService.decrypt(test)
            
            if string != nil { // Passed the encryption test and the password is valid.
                
                if method != .biometrics && didBiometricsFail && userSettings.shouldUseBiometrics {
                    try? LockView.updateBiometrics(password) // Master password may have changed and biometrics have failed. Try to update them with the correct password.
                } else {
                    print("No need to update biometrics")
                }
                
                // MARK: Why I added a fake login delay
                /// Much like how vacuums are designed to be loud and many services have fake loading bars, OpenSesame uses a short login delay so the user feels how secure it is. CryptoKit is so incredibly fast and low level that this would load instantly (much like iCloud Keychain), but this gives it a more solid feel.
                /// This may be removed in the future.
#if DEBUG
                let loginDelay: Double = 0 // Remove the login delay when debugging
#else
                let loginDelay: Double = 1.5
#endif
                isAuthenticating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + loginDelay) {
                    onSuccessfulUnlock()
                    self.password = ""
                    
                    isAuthenticating = false
                    didBiometricsFail = false
                    
                    attempts = 0
                }
                
                print("Unlocked")
            } else {
                attempts += 1
                print("Failed to unlock for the", attempts, "time.", "Password used:", password)
                
                if method == .biometrics {
                    didBiometricsFail = true
                }
            }
        }
    }
    
    func unlockWithBiometrics() {
        do {
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
            if let masterPassword = try Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
                .synchronizable(false)
                .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
                .authenticationPrompt("Authenticate to view your accounts")
                .get("masterPassword") {
                unlock(masterPassword, method: .biometrics)
            } else {
                print("Biometrics failed")
                didBiometricsFail = true
            }
        } catch {
            print(error)
            didBiometricsFail = false
        }
    }
}
