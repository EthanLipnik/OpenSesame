//
//  BoardingView+Setup.swift
//  BoardingView+Setup
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

extension BoardingView {
    struct SetupView: View {
        @Binding var encryptionTestDoesntExist: Bool
        @Binding var selectedIndex: Int
        let completion: (String) -> Void
        
        @State private var masterPassword: String = ""
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Setup")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                VStack {
                    SecureField("Master password", text: $masterPassword)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                        .disabled(!encryptionTestDoesntExist)
                    Text(encryptionTestDoesntExist || !masterPassword.isEmpty ? masterPassword : "Password already created")
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Tertiary"))
                )
                Text("Create a master password to secure your accounts and cards.")
                    .foregroundColor(Color.secondary)
                Spacer()
                Button {
                    withAnimation {
                        selectedIndex += 1
                    }
                    
                    guard !masterPassword.isEmpty && encryptionTestDoesntExist else { return }
                    completion(masterPassword)
                } label: {
                    Text("Continue")
                        .font(.title.bold())
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            .padding(30)
        }
    }
}
