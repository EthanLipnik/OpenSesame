//
//  LockView+TextField.swift
//  LockView+TextField
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import KeychainAccess

extension LockView {
    var textField: some View {
        GroupBox {
            HStack {
                SecureField("Master password", text: $password, onCommit: {
                    guard !password.isEmpty else { return }
                    unlock(password)
                })
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocussed)
#if EXTENSION
                    .frame(maxWidth: .infinity)
#else
                    .frame(maxWidth: 400)
#endif
                    .accessibilityIdentifier("masterPassword")
#if os(macOS) // macOS should display differently since a red background looks weird.
                if attempts > 0 {
                    Text(attempts, format: .number)
                        .bold()
                        .foregroundColor(Color.red)
                        .frame(width: 20)
                }
#else
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color.red).aspectRatio(1/1, contentMode: .fit)
                    Text(attempts, format: .number)
                        .bold()
                        .foregroundColor(Color.white)
                        .animation(.none, value: attempts)
                }
                .frame(height: 35)
                .opacity(attempts > 0 ? 1 : 0)
                .blur(radius: attempts > 0 ? 0 : 10)
                .animation(.default, value: attempts)
#endif
                unlockButtons
            }
        }
    }
}
