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
    @State var isAddingVerificationCode: Bool = false
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
        let otherAccounts = accounts.filter({ $0.objectID != account.objectID }).map({ $0 })
        
        let columns: [GridItem] = {
            #if os(macOS)
            return [.init(), .init()]
            #else
            return UIDevice.current.userInterfaceIdiom == .pad ? [.init(), .init()] : [.init()]
            #endif
        }()
        
        ScrollView {
            content
            
            VStack {
                if !otherAccounts.isEmpty {
                    Text("Other Accounts")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVGrid(columns: columns) {
                        ForEach(otherAccounts) { account in
                            NavigationLink {
                                AccountView(account: account)
                            } label: {
                                GroupBox {
                                    HStack {
                                        if let domain = account.domain {
                                            FaviconView(website: domain)
                                                .frame(width: 40, height: 40)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(account.domain ?? "Unknwon domain")
                                                .bold()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(account.username ?? "Unknown email or username")
                                                .foregroundColor(Color.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 800)
            
            Spacer()
                .frame(maxWidth: .infinity)
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark.circle.fill" : "pencil")
                }
            }
            ToolbarItem {
                Button {
                    isSharing.toggle()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .halfSheet(isPresented: $isSharing) {
                    ShareSheet(
                        activityItems: [try! AccountDocument(account).save()],
                        excludedActivityTypes: [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .postToFacebook, .postToVimeo, .postToWeibo, .postToFlickr, .postToTwitter, .postToTencentWeibo, .print, .saveToCameraRoll]
                    )
                        .ignoresSafeArea()
                        .onDisappear {
                            isSharing = false
                        }
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
