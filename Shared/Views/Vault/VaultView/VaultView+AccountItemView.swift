//
//  VaultView+AccountItemView.swift
//  VaultView+AccountItemView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    struct AccountItemView: View {
        let account: Account
        @Binding var selectedAccount: Account?
        
        var body: some View {
            var attributedDomain = AttributedString(((account.url?.isEmpty ?? true) ? nil : account.url) ?? account.domain ?? "Unknown website")
            if let domain = account.domain {
                if let match = attributedDomain.range(of: domain, options: [.caseInsensitive, .diacriticInsensitive]) {
                    attributedDomain.foregroundColor = Color.secondary
                    attributedDomain[match].foregroundColor = Color("Label")
                }
            }
            
            return NavigationLink(tag: account, selection: $selectedAccount) {
                AccountView(account: account)
            } label: {
                VStack(alignment: .leading) {
                    Text(attributedDomain)
                        .bold()
                        .lineLimit(1)
                    Text(account.username!)
                        .foregroundColor(Color.secondary)
                        .lineLimit(1)
                        .blur(radius: CommandLine.arguments.contains("-marketing") ? 5 : 0)
                }
            }
        }
    }
}
