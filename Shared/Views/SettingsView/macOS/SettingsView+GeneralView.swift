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
        @Environment(\.managedObjectContext) private var viewContext
        
        // MARK: - Variables
        @State var canUseBiometrics: Bool = true
        @State var passwordForgivenessDuration: Int = 0
        
        @State var canLoadWebsiteFavicon: Bool = true
        @State var colorScheme: Int = 0
        
        @State private var newMasterPassword: String = ""
        
        // MARK: - View
        var body: some View {
            VStack(spacing: 20) {
                authenticationView
                appearanceView
            }
            .padding()
        }
        
        // MARK: - AppearanceView
        var appearanceView: some View {
            VStack {
                Text("Appearance")
                    .frame(maxWidth: .infinity, alignment: .leading)
                GroupBox {
                    VStack(alignment: .leading) {
                        Toggle("Load Website Favicon", isOn: $canLoadWebsiteFavicon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        Picker("Color Scheme:", selection: $colorScheme) {
                            Text("System")
                                .tag(0)
                            Text("Light")
                                .tag(1)
                            Text("Dark")
                                .tag(2)
                        }
                        .pickerStyle(.radioGroup)
                    }.padding(5)
                }
            }
        }
        
        // MARK: - AuthenticationView
        var authenticationView: some View {
            VStack {
                Text("Authentication")
                    .frame(maxWidth: .infinity, alignment: .leading)
                GroupBox {
                    VStack(alignment: .leading) {
                        Toggle("Use Biometrics", isOn: $canUseBiometrics)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        Picker("Require password after:", selection: $passwordForgivenessDuration) {
                            Text("Immediately")
                                .tag(0)
                            Text("15 seconds")
                                .tag(1)
                            Text("1 minute")
                                .tag(2)
                            Text("5 minutes")
                                .tag(3)
                        }
                        .pickerStyle(.radioGroup)
                    }.padding(5)
                }
            }
        }
    }
}
