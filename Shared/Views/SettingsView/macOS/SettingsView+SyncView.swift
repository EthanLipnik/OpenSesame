//
//  SettingsView+SyncView.swift
//  SettingsView+SyncView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI
import AuthenticationServices

extension SettingsView {
    struct SyncView: View {
        let persistenceController = PersistenceController.shared
        
        var body: some View {
            VStack {
                Text("Syncing")
                    .frame(maxWidth: .infinity, alignment: .leading)
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack {
                            Label("iCloud", systemImage: "key.icloud.fill")
                            Spacer()
                            Button("Upload") {
                                do {
                                    try persistenceController.uploadStoreTo(.iCloud)
                                } catch {
                                    print(error)
                                }
                            }
                            
                            Button("Download") {
                                do {
                                    try persistenceController.downloadStoreFrom(.iCloud)
                                } catch {
                                    print(error)
                                }
                            }.disabled(true)
                        }
                        
                        Button("Reset autofill", role: .destructive) {
                            ASCredentialIdentityStore.shared.getState { state in
                                ASCredentialIdentityStore.shared.removeAllCredentialIdentities { success, error in
                                    print(success, error as Any)
                                }
                            }
                        }
                    }.padding(5)
                }
            }
        }
    }
}
