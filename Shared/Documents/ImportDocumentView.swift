//
//  ImportDocumentView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/23/21.
//

import SwiftUI
import UniformTypeIdentifiers
import CryptoKit

struct ImportDocumentView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    
    // MARK: - CoreData Variables
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    var vaults: FetchedResults<Vault>
    
    // MARK: - Variables
    let file: File
    @State private var selectedVault: Vault? = nil
    @State private var isAuthorizing: Bool = false
    
    // MARK: - View
    var body: some View {
        List {
            Section {
                ForEach(vaults) { vault in
                    Button {
                        selectedVault = vault
                    } label: {
                        HStack {
                            Label(vault.name!.capitalized, systemImage: "lock.square.stack.fill")
                            Spacer()
                            if selectedVault == vault {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }
            
            if selectedVault != nil {
                Section {
                    Button("Add") {
                        isAuthorizing = true
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(file.url.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .halfSheet(isPresented: $isAuthorizing) {
            AuthenticationView(onSuccess: { password in
                isAuthorizing = false
                
                do {
                    try add(encryptionKey: CryptoSecurityService.generateKey(fromString: password)!)
                } catch {
                    print(error)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss.callAsFunction()
                }
            }) {
                isAuthorizing = false
                dismiss.callAsFunction()
            }
        }
    }
    
    private func add(encryptionKey: SymmetricKey) throws {
        guard let data = FileManager.default.contents(atPath: file.url.path) else { throw CocoaError(.fileReadCorruptFile) }
        
        let type = UTType(filenameExtension: file.url.pathExtension)!
        switch type {
        case .accountDocument:
            let accountDoc = try JSONDecoder().decode(AccountDocument.self, from: data)
            
            let account = Account(context: viewContext)
            account.domain = accountDoc.domain
            account.url = accountDoc.website
            account.username = accountDoc.username
            account.password = try CryptoSecurityService.encrypt(accountDoc.password, encryptionKey: encryptionKey)
            account.passwordLength = Int16(accountDoc.password.count)
            
            selectedVault?.addToAccounts(account)
        case .cardDocument:
            let cardDoc = try JSONDecoder().decode(CardDocument.self, from: data)
            
            let card = Card(context: viewContext)
            card.expirationDate = cardDoc.expirationDate
            card.holder = cardDoc.holder
            card.name = cardDoc.name
            
            card.number = try CryptoSecurityService.encrypt(cardDoc.number, encryptionKey: encryptionKey)
            
            selectedVault?.addToCards(card)
        case .noteDocument:
            let noteDoc = try JSONDecoder().decode(NoteDocument.self, from: data)
            
            let note = Note(context: viewContext)
            note.name = noteDoc.name
            note.color = Int16(noteDoc.color)
            note.body = try CryptoSecurityService.encrypt(noteDoc.body, encryptionKey: encryptionKey)
            
            selectedVault?.addToNotes(note)
        default:
            break
        }
        
        try viewContext.save()
    }
}

struct ImportDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        ImportDocumentView(file: .init(url: .init(fileURLWithPath: "/dev/null")))
    }
}

struct File: Identifiable {
    var id: String {
        url.absoluteString
    }
    var url: URL
}
