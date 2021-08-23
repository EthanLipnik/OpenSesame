//
//  VaultView+List.swift
//  VaultView+List
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension VaultView {
    var list: some View {
        List {
            ForEach(search.isEmpty ? accounts.map({ $0 }) : accounts.filter({ account in
                let website = account.domain?.lowercased() ?? ""
                let username = account.username?.lowercased() ?? ""
                
                return website.contains(search.lowercased()) || username.contains(search.lowercased())
            })) { account in
                ItemView(account: account, selectedAccount: $selectedAccount)
                .contextMenu {
                    Button {
                        
                        account.isPinned.toggle()
                        
                        try? viewContext.save()
                    } label: {
                        Label(account.isPinned ? "Unpin" : "Pin", systemImage: account.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        shouldDeleteAccount.toggle()
                    }
                }
                .confirmationDialog("Are you sure you want to delete this account? You cannot retreive it when it is gone.", isPresented: $shouldDeleteAccount) {
                    Button("Delete", role: .destructive) {
//                        viewContext.delete(account)
                        #warning("This will delete the first account")
                    }
                    
                    Button("Cancel", role: .cancel) {
                        shouldDeleteAccount = false
                    }.keyboardShortcut(.defaultAction)
                }
            }.onDelete(perform: deleteItems)
        }
    }
}
