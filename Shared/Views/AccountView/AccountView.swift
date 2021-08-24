//
//  AccountView.swift
//  AccountView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI

struct AccountView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    
    // MARK: - CoreData
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var accounts: FetchedResults<Account>
    
    // MARK: - Variables
    let account: Account
    @State var isEditing: Bool = false
    @State var newNotes: String = ""
    
    @State private var isAddingAlternateDomains: Bool = false
    @State private var newAlternateDomains: String = ""
    @State private var isSharing: Bool = false
    
    // MARK: - Init
    init(account: Account) {
        self.account = account
        
        let predicate = NSPredicate(format: "domain contains[c] %@", account.domain!)
        self._accounts = FetchRequest(sortDescriptors: [], predicate: predicate, animation: .default)
        
        self._newNotes = .init(initialValue: account.notes ?? "")
    }
    
    // MARK: - View
    var body: some View {
//        let otherAccounts = accounts.filter({ $0.username != account.username }).map({ $0 })
        
        ScrollView {
            content
            
//            VStack {
//                if !otherAccounts.isEmpty {
//                    Text("Other Accounts")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    LazyVStack {
//                        ForEach(otherAccounts) { account in
//                            NavigationLink {
//                                AccountView(account: account)
//                            } label: {
//                                GroupBox {
//                                    HStack {
//                                        FaviconView(website: "https://" + account.domain)
//                                            .frame(width: 40, height: 40)
//                                        VStack(alignment: .leading) {
//                                            Text(account.domain)
//                                                .bold()
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                            Text(account.username)
//                                                .foregroundColor(Color.secondary)
//                                        }
//                                    }
//                                }
//                            }.buttonStyle(.plain)
//                        }
//                    }
//                }
//            }.padding()
        }
        .sheet(isPresented: $isSharing) {
            MultipeerShareSheet(account: account)
        }
#if os(iOS)
        .navigationTitle(account.domain?.capitalizingFirstLetter() ?? "")
        .toolbar {
            ToolbarItem {
                Button {
                    isSharing.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
            }
        }
#else
        .frame(minWidth: 300)
#endif
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(account: .init())
    }
}
