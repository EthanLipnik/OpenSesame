//
//  ContentView+List.swift
//  ContentView+List
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension ContentView {
    var list: some View {
        List {
            vaultSection
            
            pinnedSections
        }
        .listStyle(.sidebar)
    }
    
    private var vaultSection: some View {
        Section("Vaults") {
            if isCreatingNewVault {
                TextField("New Vault", text: $newVaultName, onCommit: {
                    addItem(withName: newVaultName)
                    
                    newVaultName = ""
                    isNewVaultFocused = false
                    withAnimation {
                        isCreatingNewVault = false
                    }
                })
                    .textFieldStyle(.roundedBorder)
                    .focused($isNewVaultFocused)
            }
            ForEach(vaults) { vault in
                if vaultToBeRenamed == vault {
                    TextField("Vault Name", text: $newVaultName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            vault.name = newVaultName
                            
                            try? viewContext.save()
                            
                            newVaultName = ""
                            vaultToBeRenamed = nil
                        }
                } else {
                    NavigationLink(tag: vault, selection: $selectedVault) {
                        VaultView(vault: vault)
                    } label: {
                        Label(vault.name!.capitalized, systemImage: "lock.square.stack.fill")
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            vaultToBeDeleted = vault
                            shouldDeleteVault.toggle()
                        }
                        Button("Rename") {
                            isCreatingNewVault = false
                            newVaultName = vault.name ?? ""
                            vaultToBeRenamed = vault
                        }
                    }
                    .swipeActions {
                        Button("Rename") {
                            isCreatingNewVault = false
                            newVaultName = vault.name ?? ""
                            vaultToBeRenamed = vault
                        }.tint(.accentColor)
                        
                        Button("Delete", role: .destructive) {
                            vaultToBeDeleted = vault
                            shouldDeleteVault.toggle()
                        }
                    }
                }
            }.onDelete { indexSet in
                vaultToBeDeleted = vaults[indexSet.first!]
                shouldDeleteVault.toggle()
            }
        }
    }
    
    private var pinnedSections: some View {
        Group {
            if !pinnedAccounts.isEmpty {
                pinnedAccountsView
            }
            
            if !pinnedCards.isEmpty {
                pinnedCardsView
            }
        }
    }
    
    private var pinnedAccountsView: some View {
        Section(pinnedCards.isEmpty ? "Pinned" : "Pinned Accounts") {
            ForEach(pinnedAccounts) { account in
                NavigationLink {
                    if let vault = account.vault {
                        VaultView(vault: vault, selectedItem: .init(account))
                    } else {
                        Text("Failed to get vault for pinned account")
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(account.domain!.capitalizingFirstLetter())
                            .bold()
                        Text(account.username!)
                            .foregroundColor(Color.secondary)
                    }
                }
                .contextMenu {
                    Button {
                        account.isPinned = false
                        
                        try? viewContext.save()
                    } label: {
                        Label("Unpin", systemImage: "pin.slash")
                    }
                    
                }
            }.onDelete { index in
                index.map({ pinnedAccounts[$0] }).forEach({ $0.isPinned = false })
            }
        }
    }
    
    private var pinnedCardsView: some View {
        Section(pinnedAccounts.isEmpty ? "Pinned" : "Pinned Cards") {
            ForEach(pinnedCards) { card in
                NavigationLink {
                    if let vault = card.vault {
                        VaultView(vault: vault, selectedItem: .init(card))
                    } else {
                        Text("Failed to get vault for pinned card")
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text(card.name!)
                            .bold()
                        Text(card.holder!)
                            .foregroundColor(Color.secondary)
                    }
                }
                .contextMenu {
                    Button {
                        card.isPinned = false
                        
                        try? viewContext.save()
                    } label: {
                        Label("Unpin", systemImage: "pin.slash")
                    }
                    
                }
            }.onDelete { index in
                index.map({ pinnedCards[$0] }).forEach({ $0.isPinned = false })
            }
        }
    }
}
