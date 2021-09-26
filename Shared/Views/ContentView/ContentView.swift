//
//  ContentView.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import CoreData
#if canImport(UIKit)
import UIKit
#endif

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
    
    @State var showSettings: Bool = false
    
    @State private var openedFile: File? = nil
    
    @AppStorage("didRequestReview") var didRequestReview: Bool = false
    @State var shouldShowReviewRequest: Bool = false
    
#if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalClass
#else
    enum HorizontalClass {
        case compact
        case regular
    }
    let horizontalClass = HorizontalClass.regular
#endif
    
    // MARK: - View
    var body: some View {
        Group {
            if horizontalClass == .regular {
                NavigationView {
                    list
                    
                    // Add empty views for when the NavigationView is empty.
                    List {}
#if os(macOS)
                    .listStyle(.inset(alternatesRowBackgrounds: true))
#endif
                    EmptyView()
                }
            } else {
                NavigationView {
                    list
                }
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
        .onAppear {
            if UserDefaults.standard.bool(forKey: "hasBeenlaunched") {
                shouldShowReviewRequest = true
            } else {
                UserDefaults.standard.set(true, forKey: "hasBeenlaunched")
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
