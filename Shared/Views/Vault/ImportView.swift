//
//  ImportView.swift
//  ImportView
//
//  Created by Ethan Lipnik on 8/20/21.
//

import CSV
import SwiftUI

struct ImportView: View {
    // MARK: - Environment

    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.dismiss)
    var dismiss

    // MARK: - CoreData Variables

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    var vaults: FetchedResults<Vault>

    // MARK: - Variables

    @StateObject
    var importManager: ImportManager
    @State
    var isPresentingImporter: Bool = true

    @State
    var selectedVault: Int = 0

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
                if importManager.isImporting {
                    ProgressView(
                        "Progress",
                        value: Double(importManager.progress) /
                            Double(importManager.importedAccounts.count)
                    )
                }
                Section {
                    Picker("Vault", selection: $selectedVault) {
                        ForEach(0 ..< vaults.count, id: \.self) {
                            Text(vaults[$0].name!)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onAppear {
                        importManager.selectedVault = vaults[selectedVault]
                    }
                    .onChange(of: selectedVault) { _ in
                        importManager.selectedVault = vaults[selectedVault]
                    }
                }
#endif
                ForEach(importManager.importedAccounts) { account in
                    HStack {
                        if account.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.accentColor)
                        }
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            if !account.username.isEmpty {
                                Text(account.username)
                                    .foregroundColor(Color.secondary)
                            }
                        }
                    }
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

                    if importManager.isImporting {
                        ProgressView(
                            "Progress",
                            value: Double(importManager.progress) /
                                Double(importManager.importedAccounts.count)
                        )
                    } else {
                        Spacer()
                    }

                    Picker("Vault", selection: $selectedVault) {
                        ForEach(0 ..< vaults.count, id: \.self) {
                            Text(vaults[$0].name!)
                                .tag($0)
                        }
                    }
                    .frame(width: 200)
                    Button("Import", role: .destructive) {
                        importManager.save { error in
                            if let error {
                                fatalError(error.localizedDescription)
                            } else {
                                print("Saved all accounts")
                                dismiss.callAsFunction()
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(importManager.isImporting)
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
                .disabled(importManager.isImporting)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Import", role: .destructive) {
                    importManager.save { error in
                        if let error {
                            print(error)
                        } else {
                            print("Saved all accounts")
                        }

                        dismiss.callAsFunction()
                        UserDefaults.standard.set(true, forKey: "didShowBoardingScreen")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(importManager.isImporting)
            }
        }
#endif
        .fileImporter(
            isPresented: $isPresentingImporter,
            allowedContentTypes: [.json, .commaSeparatedText]
        ) { result in
            switch result {
            case let .success(url):
                importManager.importFromFile(url)
            case let .failure(error):
                print(error)

#if os(macOS)
                NSAlert(error: error).runModal()
#endif

                dismiss.callAsFunction()
            }
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(importManager: .init(appFormat: .browser))
    }
}
