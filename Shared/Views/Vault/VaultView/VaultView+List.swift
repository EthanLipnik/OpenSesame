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
            if !cards.isEmpty {
                Section("Cards") {
                    ForEach(search.isEmpty ? cards.map({ $0 }) : cards.filter({ $0.name?.lowercased().contains(search.lowercased()) ?? false })) { card in
                        CardItemView(card: card, selectedCard: $selectedCard)
                    }
                }
            }
            Section("Accounts") {
                ForEach(search.isEmpty ? accounts.map({ $0 }) : accounts.filter({ account in
                    let website = account.domain?.lowercased() ?? ""
                    let username = account.username?.lowercased() ?? ""
                    
                    return website.contains(search.lowercased()) || username.contains(search.lowercased())
                })) { account in
                    AccountItemView(account: account, selectedAccount: $selectedAccount)
                    .contextMenu {
                        Button {
                            
                            account.isPinned.toggle()
                            
                            try? viewContext.save()
                        } label: {
                            Label(account.isPinned ? "Unpin" : "Pin", systemImage: account.isPinned ? "pin.slash" : "pin")
                        }
                        Button("Delete", role: .destructive) {
                            accountToBeDeleted = account
                            shouldDeleteAccount.toggle()
                        }
                    }
                }.onDelete(perform: deleteItems)
            }
        }
        .confirmationDialog("Are you sure you want to delete this account? You cannot retreive it when it is gone.", isPresented: $shouldDeleteAccount) {
            Button("Delete", role: .destructive) {
                deleteItems(offsets: IndexSet([accounts.firstIndex(of: accountToBeDeleted!)!]))
            }
            
            Button("Cancel", role: .cancel) {
                shouldDeleteAccount = false
            }.keyboardShortcut(.defaultAction)
        }
    }
}
