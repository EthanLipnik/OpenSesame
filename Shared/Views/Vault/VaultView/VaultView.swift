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
    
    // MARK: - Variables
    let vault: Vault
    
    @State var selectedAccount: Account? = nil
    
    @State var shouldDeleteAccount: Bool = false
    @State var accountToBeDeleted: Account? = nil
    
    @State var isCreatingNewAccount: Bool = false
    @State var search: String = ""
    
    // MARK: - Init
    init(vault: Vault, selectedAccount: Account? = nil) {
        self.vault = vault
        self._selectedAccount = .init(initialValue: selectedAccount)
        
        self._accounts = FetchRequest(sortDescriptors: [.init(key: "domain", ascending: true)],
                                      predicate: NSPredicate(format: "vault == %@", vault), animation: .default)
    }
    
    // MARK: - View
    var body: some View {
        list
        .sheet(isPresented: $isCreatingNewAccount) {
            NewAccountView(vault: 0)
        }
        .searchable(text: $search)
#if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .navigationTitle("OpenSesame – " + (vault.name ?? "Unknown vault"))
        .frame(minWidth: 200)
#else
        .listStyle(.insetGrouped)
        .navigationTitle(vault.name!)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .onOpenURL { url in
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let query = components.query, let url = components.string?.replacingOccurrences(of: "?" + query, with: ""), let queryItems = components.queryItems {
                if let type = queryItems.first(where: { $0.name == "type" }), type.value == "account", url == "openSesame://new" {
                    addItem()
                }
            } else {
                print("Badly formatted URL")
            }
        }
    }
    
    private func addItem() {
        isCreatingNewAccount = true
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
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
