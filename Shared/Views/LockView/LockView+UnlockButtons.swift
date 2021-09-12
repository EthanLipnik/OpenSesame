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
#if os(iOS)
            .hoverEffect()
#endif
            
            if let image = image, !biometricsFailed && userSettings.shouldUseBiometrics {
                Button {
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
                        if let masterPassword = try OpenSesameKeychain()
                            .synchronizable(false)
                            .accessibility(accessibility, authenticationPolicy: authenticationPolicy)
                            .authenticationPrompt("Authenticate to view your accounts")
                            .get("masterPassword") {
                            unlock(masterPassword, method: .biometrics)
                        } else {
                            print("Biometrics failed")
                            biometricsFailed = true
                        }
                    } catch {
                        print(error)
                        biometricsFailed = false
                    }
                } label: {
                    Image(systemName: image)
#if os(iOS)
                        .imageScale(.large)
#endif
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
#if os(iOS)
            .hoverEffect()
#endif
            }
        }
    }
}
