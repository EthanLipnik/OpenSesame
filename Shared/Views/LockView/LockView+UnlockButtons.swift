//
//  LockView+UnlockButtons.swift
//  LockView+UnlockButtons
//
//  Created by Ethan Lipnik on 8/22/21.
//

import KeychainAccess
import SwiftUI

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

            if let image = image, userSettings.shouldUseBiometrics {
                Button(action: unlockWithBiometrics) {
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
