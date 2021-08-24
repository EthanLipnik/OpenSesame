//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        Form {
            // MARK: - Syncing
            Section("Syncing") {
                HStack {
                    Label("iCloud", systemImage: "key.icloud.fill")
                    Spacer()
                    Button {
                        try! persistenceController.uploadStoreTo(.iCloud)
                    } label: {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                    
                    Divider()
                    
                    Button {
                        try! persistenceController.downloadStoreFrom(.iCloud)
                    } label: {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                }.buttonStyle(.plain)
            }
        }
            .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
