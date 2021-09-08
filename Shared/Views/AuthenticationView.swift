//
//  AuthenticationView.swift
//  AuthenticationView
//
//  Created by Ethan Lipnik on 9/7/21.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var authenticatedPassword: String = ""
    let onSuccess: (_ password: String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70)
            GroupBox {
                HStack {
                    SecureField("Master password", text: $authenticatedPassword)
                        .onSubmit(didAuthenticate)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: 400)
                    Button(action: didAuthenticate) {
                        Image(systemName: "key.fill")
                    }
                }
            }
        }.padding()
    }
    
    func didAuthenticate() {
        guard !authenticatedPassword.isEmpty, CryptoSecurityService.runEncryptionTest(authenticatedPassword) else { return }
        
        onSuccess(authenticatedPassword)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView() { password in
            
        }
    }
}
