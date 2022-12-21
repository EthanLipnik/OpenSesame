//
//  LockView+CreatePassword.swift
//  LockView+CreatePassword
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension LockView {
    struct CreatePasswordView: View {
        @State
        private var password: String = ""
        let completionAction: (String) -> Void

        var body: some View {
            VStack {
                Text("Welcome to OpenSesame")
                    .font(.title.bold())
                GroupBox {
                    TextField("Enter a new master password", text: $password, onCommit: {
                        guard !password.isEmpty else { return }
                        completionAction(password)
                    })
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
#if os(iOS)
                        .autocapitalization(.none)
#endif
                }
                Button("Continue") {
                    guard !password.isEmpty else { return }
                    completionAction(password)
                }
            }
            .padding()
            .interactiveDismissDisabled()
        }
    }
}
