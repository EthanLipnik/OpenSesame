//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/18/21.
//

#if os(macOS)
import KeychainAccess
import SwiftUI

struct SettingsView: View {
    // MARK: - Environment

    @StateObject
    var userSettings = UserSettings.default
    @State
    private var selectedTab: Int = 0

    // MARK: - View

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralView()
                .environmentObject(userSettings)
                .padding()
                .tabItem {
                    Label("General", systemImage: "gearshape.fill")
                }
                .tag(0)
            SecurityView()
                .environmentObject(userSettings)
                .padding()
                .tabItem {
                    Label("Security", systemImage: "lock.fill")
                }
                .tag(1)
            SyncView()
                .environmentObject(userSettings)
                .padding()
                .tabItem {
                    Label("Syncing", systemImage: "cloud.fill")
                }
                .tag(2)
//            TipJarView()
//                .tabItem {
//                    Label("Tip Jar", systemImage: "heart.fill")
//                }
//                .tag(3)
        }
        .frame(width: 450, height: selectedTab == 3 ? 200 : nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
