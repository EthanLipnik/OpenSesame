//
//  VaultView.swift
//  VaultView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import AuthenticationServices
import Foundation

struct VaultView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - CoreData Variables
    @FetchRequest var accounts: FetchedResults<Account>
    @FetchRequest var cards: FetchedResults<Card>
    
    // MARK: - Variables
    let vault: Vault
    
    @StateObject var viewModel: ViewModel
    
    @State var shouldDeleteAccount: Bool = false
    @State var shouldDeleteCard: Bool = false
    @State var itemToBeDeleted: Item? = nil
    
    @State var isCreatingNewItem: Bool = false
    @State var itemToCreate: ItemCreationType = .none
    
    @State var search: String = ""
    
    enum ItemCreationType: String {
        case account = "account"
        case card = "card"
        case none = "none"
    }
    
    // MARK: - Init
    init(vault: Vault, selectedItem: Item? = nil) {
        self.vault = vault
        
        self._accounts = FetchRequest(sortDescriptors: [.init(key: "domain", ascending: true)],
                                      predicate: NSPredicate(format: "vault == %@", vault), animation: .default)
        self._cards = FetchRequest(sortDescriptors: [],
                                   predicate: NSPredicate(format: "vault == %@", vault), animation: .default)
        
        let viewModel = ViewModel()
        if let selectedItem = selectedItem {
            viewModel.selectedItem = selectedItem
            viewModel.selectedItems.insert(selectedItem)
        }
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - View
    var body: some View {
        list
#if os(macOS)
            .sheet(isPresented: $isCreatingNewItem) {
                if itemToCreate == .account {
                    NewAccountView(selectedVault: vault)
                } else if itemToCreate == .card {
                    NewCardView(selectedVault: vault)
                }
            }
            .onChange(of: itemToCreate) { print("Creating item", $0.rawValue) } // This line is for some reason required for the sheet to display properly in macOS
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .navigationTitle("OpenSesame – " + (vault.name ?? "Unknown vault"))
            .frame(minWidth: 200)
#else
            .halfSheet(showSheet: $isCreatingNewItem) {
                Group {
                    if itemToCreate == .account {
                        NewAccountView(selectedVault: vault)
                    } else if itemToCreate == .card {
                        NewCardView(selectedVault: vault)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(vault.name ?? "Vault")
#endif
            .searchable(text: $search)
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Menu {
                        Button {
                            itemToCreate = .account
                            isCreatingNewItem.toggle()
                        } label: {
                            Label("Add Account", systemImage: "person")
                        }
                        Button {
                            itemToCreate = .card
                            isCreatingNewItem.toggle()
                        } label: {
                            Label("Add Card", systemImage: "creditcard")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .onOpenURL { url in
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let query = components.query, let url = components.string?.replacingOccurrences(of: "?" + query, with: ""), let queryItems = components.queryItems {
                    if let type = queryItems.first(where: { $0.name == "type" }), url == "openSesame://new" {
                        switch type.value {
                        case "account":
                            itemToCreate = .account
                            isCreatingNewItem = true
                        case "card":
                            itemToCreate = .card
                            isCreatingNewItem = true
                        default:
                            break
                        }
                    }
                } else {
                    print("Badly formatted URL")
                }
            }
    }
    
    func deleteItems(offsets: IndexSet, type: ItemCreationType) {
        withAnimation {
            if type == .account {
                offsets.map { accounts[$0] }.forEach { account in
                    
                    let domainIdentifer = ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: account.domain!, type: .domain),
                                                                       user: account.username!,
                                                                       recordIdentifier: nil)
                    
                    ASCredentialIdentityStore.shared.removeCredentialIdentities([domainIdentifer]) { success, error in
                        if let error = error {
                            print("Failed to remove credential", error)
                            
#if os(macOS)
                            NSAlert(error: NSError(domain: "Failed to delete credential for autofill: \(error.localizedDescription)", code: 0, userInfo: nil)).runModal()
#endif
                        }
                    }
                    
                    viewContext.delete(account)
                }
            } else {
                offsets.map { cards[$0] }.forEach(viewContext.delete)
            }
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct VaultView_Previews: PreviewProvider {
    static var previews: some View {
        VaultView(vault: .init())
    }
}
