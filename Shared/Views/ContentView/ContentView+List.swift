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
            
            if !pinnedAccounts.isEmpty {
                pinnedSection
            }
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
                }
            }
            .onDelete { indexSet in
                vaultToBeDeleted = vaults[indexSet.first!]
                shouldDeleteVault.toggle()
            }
        }
    }
    
    private var pinnedSection: some View {
        Section("Pinned") {
            ForEach(pinnedAccounts) { account in
                NavigationLink {
                    if let vault = account.vault {
                        VaultView(vault: vault, selectedAccount: account)
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
}
