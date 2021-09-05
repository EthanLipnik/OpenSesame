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
                if accounts.isEmpty {
                    cardsList
                } else {
                    Section("Cards") {
                        cardsList
                    }
                }
            }
            
            if !accounts.isEmpty {
                if cards.isEmpty {
                    accountsList
                } else {
                    Section("Accounts") {
                        accountsList
                    }
                }
            }
        }
        .confirmationDialog("Are you sure you want to delete this account? You cannot retreive it when it is gone.", isPresented: $shouldDeleteAccount) {
            Button("Delete", role: .destructive) {
                deleteItems(offsets: IndexSet([accounts.firstIndex(of: itemToBeDeleted!.account!)!]), type: .account)
            }
            
            Button("Cancel", role: .cancel) {
                shouldDeleteAccount = false
            }.keyboardShortcut(.defaultAction)
        }
        .confirmationDialog("Are you sure you want to delete this card? You cannot retreive it when it is gone.", isPresented: $shouldDeleteCard) {
            Button("Delete", role: .destructive) {
                deleteItems(offsets: IndexSet([cards.firstIndex(of: itemToBeDeleted!.card!)!]), type: .card)
            }
            
            Button("Cancel", role: .cancel) {
                shouldDeleteCard = false
            }.keyboardShortcut(.defaultAction)
        }
    }
    
    private var cardsList: some View {
        ForEach(search.isEmpty ? cards.map({ $0 }) : cards.filter({ $0.name?.lowercased().contains(search.lowercased()) ?? false })) { card in
            CardItemView(card: card)
                .environmentObject(viewModel)
                .contextMenu {
                    Button {
                        
                        card.isPinned.toggle()
                        
                        try? viewContext.save()
                    } label: {
                        Label(card.isPinned ? "Unpin" : "Pin", systemImage: card.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(card)
                        shouldDeleteCard.toggle()
                    }
                }
        }.onDelete { indexSet in
            itemToBeDeleted = .init(cards[indexSet.first!])
            shouldDeleteCard.toggle()
        }
    }
    
    private var accountsList: some View {
        ForEach(search.isEmpty ? accounts.map({ $0 }) : accounts.filter({ account in
            let website = account.domain?.lowercased() ?? ""
            let username = account.username?.lowercased() ?? ""
            
            return website.contains(search.lowercased()) || username.contains(search.lowercased())
        })) { account in
            AccountItemView(account: account)
                .environmentObject(viewModel)
                .contextMenu {
                    Button {
                        
                        account.isPinned.toggle()
                        
                        try? viewContext.save()
                    } label: {
                        Label(account.isPinned ? "Unpin" : "Pin", systemImage: account.isPinned ? "pin.slash" : "pin")
                    }
                    Button("Delete", role: .destructive) {
                        itemToBeDeleted = .init(account)
                        shouldDeleteAccount.toggle()
                    }
                }
        }
        .onDelete { indexSet in
            itemToBeDeleted = .init(accounts[indexSet.first!])
            shouldDeleteAccount.toggle()
        }
    }
}
