//
//  SettingsView+GeneralView.swift
//  SettingsView+GeneralView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import CoreData
import KeychainAccess

extension SettingsView {
    struct GeneralView: View {
        // MARK: - Environment
        @EnvironmentObject var userSettings: UserSettings
        
        // MARK: - View
        var body: some View {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    Text("Favicons:")
                        .frame(width: 100, alignment: .trailing)
                    VStack(alignment: .leading) {
                        Toggle("Load Favicons", isOn: $userSettings.shouldLoadFavicon)
                        Toggle("Show favicons in List", isOn: $userSettings.shouldShowFaviconInList)
                            .disabled(!userSettings.shouldLoadFavicon)
                            .padding(.leading)
                    }
                    Spacer()
                }
                HStack {
                    Text("Color Scheme:")
                        .frame(width: 100, alignment: .trailing)
                    Picker("Color Scheme", selection: $userSettings.colorScheme) {
                        Text("System")
                            .tag(0)
                        Text("Light")
                            .tag(1)
                        Text("Dark")
                            .tag(2)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .scaledToFit()
                    Spacer()
                }
            }
            .padding()
        }
    }
}
