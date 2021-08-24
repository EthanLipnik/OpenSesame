//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI
import KeychainAccess

struct SettingsView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - View
    var body: some View {
        TabView {
            GeneralView()
                .padding()
                .tabItem {
                    Label("General", systemImage: "gearshape.fill")
                }
            MenuBarView()
                .padding()
                .tabItem {
                    Label("Menu Bar", systemImage: "menubar.dock.rectangle")
                }
            SyncView()
                .padding()
                .tabItem {
                    Label("Syncing", systemImage: "arrow.clockwise")
                }
        }
        .frame(maxWidth: 450)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
