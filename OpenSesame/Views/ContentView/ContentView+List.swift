//
//  ContentView+List.swift
//  ContentView+List
//
//  Created by Ethan Lipnik on 8/22/21.
//

import CoreData
import StoreKit
import SwiftUI

extension ContentView {
    var lockButton: some View {
        Button {
            isLocked = true
        } label: {
            Label("Lock", systemImage: "lock.fill")
        }
    }

    var list: some View {
        List {
            vaultSection

            pinnedSections
        }
        .listStyle(.sidebar)
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: ToolbarItemPlacement.navigation) {
                HStack {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .sheet(isPresented: $showSettings) {
                        NavigationView {
                            SettingsView()
                                .environment(\.managedObjectContext, viewContext)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Done") {
                                            showSettings.toggle()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
#endif
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Vault", systemImage: "rectangle.stack.fill.badge.plus")
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this '\(vaultToBeDeleted?.name?.capitalized ?? "vault")'? You cannot retreive it when it is gone.",
            isPresented: $shouldDeleteVault
        ) { // COnfirmation dialogue for deleting a vault.
            Button("Delete", role: .destructive) {
                guard let vault = vaultToBeDeleted else { return }

                deleteItems(offsets: IndexSet([vaults.firstIndex(of: vault)].compactMap { $0 }))

                shouldDeleteVault = false
                vaultToBeDeleted = nil
            }

            Button("Cancel", role: .cancel) {
                shouldDeleteVault = false
                vaultToBeDeleted = nil
            }.keyboardShortcut(.defaultAction)
        }
        .navigationTitle("OpenSesame")
        .onAppear {
            guard selectedVault == nil else { return }
#if os(macOS)
            if horizontalClass == .regular {
                selectedVault = vaults.first
            }
#else
            if UIDevice.current.userInterfaceIdiom == .pad {
                selectedVault = vaults.first
            }
#endif
        }
#if !os(macOS)
        .overlay(
            vaults.isEmpty ? Text("Add a new vault")
                .multilineTextAlignment(.center)
                .font(.title.bold())
                .foregroundColor(Color.secondary) : nil
        )
#endif
        .overlay(
            (didRequestReview || !shouldShowReviewRequest) || OpenSesameApp.isMac ? nil :
                Button {
                    guard let writeReviewURL =
                        URL(
                            string: "https://apps.apple.com/app/id1581907821?action=write-review"
                        )
                    else { fatalError("Expected a valid URL") }
#if os(iOS)
                    UIApplication.shared.open(
                        writeReviewURL,
                        options: [:],
                        completionHandler: nil
                    )
#else
                    NSWorkspace.shared.open(writeReviewURL)
#endif

                    UserDefaults.standard.set(true, forKey: "didRequestReview")
                } label: {
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Material.thin)

                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Material.thick, lineWidth: 4)
                        }
                        .compositingGroup()
                        .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.accentColor)
                            VStack(alignment: .leading) {
                                Text("Enjoing OpenSesame?")
                                    .font(.headline)
                                Text("Consider giving it a review!")
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }.padding()
                    }
                }
                .frame(height: 60)
                .padding()
                .transition(.scale)
                .animation(.default, value: didRequestReview),

            alignment: .bottom
        )
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
                .textFieldStyle(.plain)
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
                            .toolbar { ToolbarItem(placement: .navigation) {
                                lockButton
                            }}
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

            if !pinnedNotes.isEmpty {
                pinnedNotesView
            }
        }
    }

    private var pinnedAccountsView: some View {
        Section(pinnedCards.isEmpty && pinnedNotes.isEmpty ? "Pinned" : "Pinned Accounts") {
            ForEach(pinnedAccounts) { account in
                VaultView.AccountItemView(account: account, isPopover: true)
                    .environmentObject(VaultView.ViewModel())
                    .contextMenu {
                        Button {
                            account.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }
                    }
                    .swipeActions {
                        Button {
                            account.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }.tint(account.isPinned ? .orange : .accentColor)
                    }
            }
            .onDelete { index in
                index.map { pinnedAccounts[$0] }.forEach { $0.isPinned = false }
            }
        }
    }

    private var pinnedCardsView: some View {
        Section(pinnedAccounts.isEmpty && pinnedNotes.isEmpty ? "Pinned" : "Pinned Cards") {
            ForEach(pinnedCards) { card in
                VaultView.CardItemView(card: card, isPopover: true)
                    .environmentObject(VaultView.ViewModel())
                    .contextMenu {
                        Button {
                            card.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }
                    }
                    .swipeActions {
                        Button {
                            card.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }.tint(card.isPinned ? .orange : .accentColor)
                    }
            }
        }
    }

    private var pinnedNotesView: some View {
        Section(pinnedAccounts.isEmpty && pinnedCards.isEmpty ? "Pinned" : "Pinned Notes") {
            ForEach(pinnedNotes) { note in
                VaultView.NoteItemView(note: note, isPopover: true)
                    .environmentObject(VaultView.ViewModel())
                    .contextMenu {
                        Button {
                            note.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }
                    }
                    .swipeActions {
                        Button {
                            note.isPinned = false

                            try? viewContext.save()
                        } label: {
                            Label("Unpin", systemImage: "pin.slash")
                        }.tint(note.isPinned ? .orange : .accentColor)
                    }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let selectedVaults = offsets.map { vaults[$0] }

            selectedVaults
                .forEach { $0.accounts?
                    .compactMap { $0 as? NSManagedObject }
                    .forEach(viewContext.delete)
                }

            selectedVaults
                .forEach(viewContext.delete)

            vaultToBeDeleted = nil
            shouldDeleteVault = false

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You
                // should not use this function in a shipping application, although it may be useful
                // during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
