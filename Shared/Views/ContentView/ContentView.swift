//
//  ContentView.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    
    // MARK: - CoreData Variables
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    var vaults: FetchedResults<Vault>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isPinned == %i", 1),
        animation: .default)
    var pinnedAccounts: FetchedResults<Account>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isPinned == %i", 1),
        animation: .default)
    var pinnedCards: FetchedResults<Card>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isPinned == %i", 1),
        animation: .default)
    var pinnedNotes: FetchedResults<Note>
    
    // MARK: - Variables
    @Binding var isLocked: Bool
    
    @FocusState var isNewVaultFocused: Bool
    @State var isCreatingNewVault: Bool = false
    @State var newVaultName: String = ""
    
    @State var selectedVault: Vault? = nil
    
    @State var shouldDeleteVault: Bool = false
    @State var vaultToBeDeleted: Vault? = nil
    @State var vaultToBeRenamed: Vault? = nil
    
    @State private var showSettings: Bool = false
    
    @State private var openedFile: File? = nil
    
#if !os(macOS) && !os(watchOS) && !os(tvOS)
    @Environment(\.horizontalSizeClass) var horizontalClass
#else
    enum HorizontalClass {
        case compact
        case large
    }
    let horizontalClass = HorizontalClass.large
#endif
    
    // MARK: - View
    var body: some View {
        NavigationView {
            list
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.navigation) {
                        HStack {
                            Button {
                                isLocked = true
                            } label: {
                                Label("Lock", systemImage: "lock.fill")
                            }
#if os(iOS)
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
#endif
                        }
                    }
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
                .confirmationDialog("Are you sure you want to delete this '\(vaultToBeDeleted?.name?.capitalized ?? "vault")'? You cannot retreive it when it is gone.", isPresented: $shouldDeleteVault) { // COnfirmation dialogue for deleting a vault.
                    Button("Delete", role: .destructive) {
                        guard let vault = vaultToBeDeleted else { return }
                        
                        deleteItems(offsets: IndexSet([vaults.firstIndex(of: vault)].compactMap({ $0 })))
                        
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
                    selectedVault = vaults.first
#else
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        selectedVault = vaults.first
                    }
#endif
                }
            
            // Add empty views for when the NavigationView is empty.
            if horizontalClass != .compact {
                List {}
#if os(macOS)
                .listStyle(.inset(alternatesRowBackgrounds: true))
#endif
                EmptyView()
                    .frame(minWidth: 300)
            }
        }
        // URL Actions for keyboard shortcuts and documents.
        .onOpenURL { url in
            selectedVault = nil
            
            guard !url.isFileURL else {
                self.openedFile = File(url: url)
                
                return
            }
            
            guard !isLocked else { return }
            
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let query = components.query, let url = components.string?.replacingOccurrences(of: "?" + query, with: ""), let queryItems = components.queryItems {
                if let type = queryItems.first(where: { $0.name == "type" }), type.value == "vault", url == "openSesame://new" {
                    addItem()
                }
            } else {
                print("Badly formatted URL")
            }
        }
        .sheet(item: $openedFile) { file in
#if os(macOS)
            ImportDocumentView(file: file)
                .environment(\.managedObjectContext, viewContext)
#else
            NavigationView {
                ImportDocumentView(file: file)
                    .environment(\.managedObjectContext, viewContext)
            }.navigationViewStyle(.stack)
#endif
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            
            let selectedVaults = offsets.map({ vaults[$0] })
            
            selectedVaults
                .forEach({ $0.accounts?
                .compactMap({ $0 as? NSManagedObject })
                    .forEach(viewContext.delete) })
            
            selectedVaults
                .forEach(viewContext.delete)
            
            vaultToBeDeleted = nil
            shouldDeleteVault = false
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isLocked: .constant(false))
    }
}

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.show(.primary)
    }
}
