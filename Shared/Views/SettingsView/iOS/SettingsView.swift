//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @State private var isImporting: Bool = false
    
    private let icons: [String] = ["Default", "Green", "Orange", "Purple", "Red", "Silver", "Space Gray"]
    
    @StateObject var userSettings = UserSettings.default
    
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
                    .disabled(true)
                }.buttonStyle(.plain)
            }
            
            Section {
                Button {
                    isImporting.toggle()
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
            Section("Appearance") {
                Picker(selection: $userSettings.selectedIcon) {
                    ForEach(icons, id: \.self) { icon in
                        HStack(alignment: .top) {
                            HStack {
                                Image("\(icon)Icon")
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(15)
                                Text(icon)
                            }
                        }.tag(icon)
                    }
                } label: {
                    Label("Icon", systemImage: "app.fill")
                }
            }
        }
            .navigationTitle("Settings")
            .sheet(isPresented: $isImporting) {
                NavigationView {
                    ImportView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .navigationTitle("Import")
                }
                .navigationViewStyle(.stack)
                .interactiveDismissDisabled()
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
