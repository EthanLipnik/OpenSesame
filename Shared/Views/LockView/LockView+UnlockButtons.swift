//
//  LockView+UnlockButtons.swift
//  LockView+UnlockButtons
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import KeychainAccess

extension LockView {
    var unlockButtons: some View {
        // Associate available biometric types to an image
        let image: String? = {
            if biometricTypes.contains(.faceID) {
                return "faceid"
            } else if biometricTypes.contains(.touchID) {
                return "touchid"
            } else if biometricTypes.contains(.watch) {
                return "lock.applewatch"
            } else {
                return nil
            }
        }()
        
        return Group {
            Button {
                unlock(password)
            } label: {
                Image(systemName: "key.fill")
#if os(iOS)
                    .imageScale(.large)
#endif
            }
            .keyboardShortcut(.defaultAction)
            .disabled(password.isEmpty)
            .accessibilityIdentifier("loginButton")
            
            if let image = image, canAuthenticateWithBiometrics || biometricsFailed {
                Button {
                    do {
#if targetEnvironment(simulator)
                        let accessibility: Accessibility = .always
#else
                        let accessibility: Accessibility = .whenUnlockedThisDeviceOnly
#endif
                        if let masterPassword = try Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
                            .accessibility(accessibility, authenticationPolicy: .biometryCurrentSet)
                            .authenticationPrompt("Authenticate to view your accounts")
                            .get("masterPassword") {
                            unlock(masterPassword, method: .biometrics)
                        } else {
                            biometricsFailed = true
                        }
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: image)
#if os(iOS)
                        .imageScale(.large)
#endif
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
            }
        }
    }
}
