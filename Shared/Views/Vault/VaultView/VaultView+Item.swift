//
//  VaultView+Item.swift
//  VaultView+Item
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    struct ItemView: View {
        let account: Account
        @Binding var selectedAccount: Account?
        
        var body: some View {
            NavigationLink(tag: account, selection: $selectedAccount) {
                AccountView(account: account)
            } label: {
                VStack(alignment: .leading) {
                    Text(account.domain!.capitalizingFirstLetter())
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
