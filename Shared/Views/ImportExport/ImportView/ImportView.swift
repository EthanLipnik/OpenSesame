//
//  ImportView.swift
//  ImportView
//
//  Created by Ethan Lipnik on 8/20/21.
//

import SwiftUI
import CSV

struct ImportView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    
    // MARK: - CoreData Variables
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    var vaults: FetchedResults<Vault>
    
    // MARK: - Variables
    @State var accounts: [ImportedAccount] = []
    @State var isPresentingImporter: Bool = true
    
    @State var isImporting: Bool = false
    @State var accountProgress: Int = 0
    
    @State var selectedVault: Int = 0
    
    @State var addedAccounts: [Account] = []
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 0) {
            /// Should use a table on macOS but performance was unusable with enough data.
            //            Table(accounts) {
            //                TableColumn("Name", value: \.name)
            //                TableColumn("URL", value: \.url)
            //                TableColumn("Username", value: \.username)
            //                TableColumn("Password", value: \.password)
            //                TableColumn("OTP Auth", value: \.otpAuth)
            //            }
            List {
#if os(iOS)
                Section {
                    Picker("Vault", selection: $selectedVault) {
                        ForEach(0..<vaults.count, id: \.self) {
                            Text(vaults[$0].name!)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.wheel)
                }
#endif
                ForEach(accounts) {
                    Text($0.name)
                }
            }
#if os(macOS)
            .listStyle(.inset(alternatesRowBackgrounds: true))
#endif
#if os(macOS)
            GroupBox {
                HStack {
                    Button("Cancel", role: .cancel) {
                        dismiss.callAsFunction()
                    }.keyboardShortcut(.cancelAction)
                    
                    if isImporting {
                        ProgressView("Progress", value: Double(accountProgress) / Double(accounts.count))
                    } else {
                        Spacer()
                    }
                    
                    Picker("Vault", selection: $selectedVault) {
                        ForEach(0..<vaults.count, id: \.self) {
                            Text(vaults[$0].name!)
                                .tag($0)
                        }
                    }
                    .frame(width: 200)
                    Button("Import", role: .destructive, action: importAccounts)
                        .keyboardShortcut(.defaultAction)
                        .disabled(isImporting)
                }.padding()
            }
#endif
        }
#if os(macOS)
        .frame(minWidth: 400, minHeight: 300)
        .frame(width: 600, height: 500)
#else
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
                    dismiss.callAsFunction()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isImporting)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isImporting {
                        ProgressView("Progress", value: Double(accountProgress) / Double(accounts.count))
                    }
                    Button("Import", role: .destructive, action: importAccounts)
                        .keyboardShortcut(.defaultAction)
                        .disabled(isImporting)
                }
            }
        }
#endif
        .fileImporter(isPresented: $isPresentingImporter, allowedContentTypes: [.commaSeparatedText]) { result in
            switch result {
            case .success(let url):
                DispatchQueue.global(qos: .userInitiated).async {
                    let stream = InputStream(url: url)!
                    let csv = try! CSVReader(stream: stream, hasHeaderRow: true).lazy
                    
                    let importedAccounts = csv.map({ ImportedAccount(name: $0[0], url: $0[1], username: $0[2], password: $0[3], otpAuth: $0[safe: 4] ?? "") })
                    
                    DispatchQueue.main.async {
                        accounts = importedAccounts.map({ $0 })
                    }
                    stream.close()
                }
            case .failure(let error):
                print(error)
                
#if os(macOS)
                NSAlert(error: error).runModal()
#endif
                
                dismiss.callAsFunction()
            }
        }
    }
    
    struct ImportedAccount: Identifiable {
        let id: UUID = UUID()
        
        var name: String
        var url: String
        var username: String
        var password: String
        var otpAuth: String
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView()
    }
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
