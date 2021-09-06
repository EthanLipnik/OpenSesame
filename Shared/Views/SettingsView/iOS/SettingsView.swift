//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    
    private let icons: [String] = ["Default", "Green", "Orange", "Purple", "Red", "Silver", "Space Gray"]
    
    @StateObject var userSettings = UserSettings.default
    
    var body: some View {
        Form {
            Section("General") {
                Button {
                    isImporting.toggle()
                } label: {
                    Label("Import", systemImage: "tray.and.arrow.down.fill")
                }
                Menu {
                    Button {
                        
                    } label: {
                        Label("Web Browser", systemImage: "globe")
                    }
                    
                    Divider()
                    Button("1Password") {
                        
                    }
                    
                    Button("Bitwarden") {
                    }
                } label: {
                    Label("Export", systemImage: "tray.and.arrow.up.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Toggle(isOn: .constant(true)) {
                    Label("Load Favicon", systemImage: "photo.fill")
                }
                .tint(.accentColor)
                Toggle(isOn: .constant(true)) {
                    Label("Sync with iCloud", systemImage: "icloud.fill")
                }
                .tint(.accentColor)
            }
            Section("Appearance") {
                HStack {
                    Label("Color Scheme", systemImage: "circle.fill")
                    Spacer()
                    Picker("Color Scheme", selection: .constant(0)) {
                        Text("System")
                            .tag(0)
                        Text("Light")
                            .tag(1)
                        Text("Dark")
                            .tag(2)
                    }
                    .pickerStyle(.menu)
                }
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
            
            Section("Security") {
                Toggle(isOn: .constant(true)) {
                    let biometricTypes = UserAuthenticationService.availableBiometrics()
                    let image: String = {
                        if biometricTypes.contains(.faceID) {
                            return "faceid"
                        } else if biometricTypes.contains(.touchID) {
                            return "touchid"
                        } else if biometricTypes.contains(.watch) {
                            return "lock.applewatch"
                        } else {
                            return "faceid"
                        }
                    }()
                    Label("Allow Biometrics", systemImage: image)
                }
                .tint(.accentColor)
                HStack {
                    Label("Auto-Lock", systemImage: "lock.fill")
                    Spacer()
                    Picker("Auto-lock", selection: .constant(0)) {
                        Text("Immedietly")
                            .tag(0)
                        Text("30s")
                            .tag(1)
                        Text("1m")
                            .tag(2)
                        Text("3m")
                            .tag(3)
                        Text("4m")
                            .tag(4)
                        Text("5m")
                            .tag(5)
                    }
                    .pickerStyle(.menu)
                }
                Toggle(isOn: .constant(true)) {
                    Label("Hide when closing app", systemImage: "eye.slash.fill")
                }
                .tint(.accentColor)
                Toggle(isOn: .constant(true)) {
                    Label("Allow Autofill", systemImage: "text.append")
                }
                .tint(.accentColor)
                Link(destination: URL(string: "https://opensesamemanager.github.com/Website")!) {
                    Label("Learn more", systemImage: "info.circle.fill")
                }
            }
            
            Section("About") {
                NavigationLink {
                    TipJarView()
                        .navigationTitle("Tip Jar")
                } label: {
                    Label("Tip Jar", systemImage: "heart.fill")
                }
                Link(destination: URL(string: "https://opensesamemanager.github.com/Website")!) {
                    Label("Website", systemImage: "globe")
                }
                Link(destination: URL(string: "https://github.com/OpenSesameManager/OpenSesame")!) {
                    Label("Source Code", systemImage: "chevron.left.slash.chevron.right")
                }
                Link(destination: URL(string: "https://github.com/OpenSesameManager/OpenSesame")!) {
                    Label("Rate OpenSesame", systemImage: "star.fill")
                }
            }
            
            Section("Self Destruct") {
                Button(role: .destructive) {
                    ASCredentialIdentityStore.shared.getState { state in
                        ASCredentialIdentityStore.shared.removeAllCredentialIdentities { success, error in
                            print(success, error as Any)
                        }
                    }
                } label: {
                    Label("Reset Autofill", systemImage: "exclamationmark.arrow.circlepath")
                }
                Button(role: .destructive) {
                    
                } label: {
                    Label("Nuke Database", systemImage: "trash.fill")
                }
            }
        }
            .navigationTitle("Settings")
            .halfSheet(showSheet: $isImporting) {
                NavigationView {
                    ImportView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .navigationTitle("Import")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(.stack)
                .interactiveDismissDisabled()
                .onDisappear {
                    isImporting = false
                }
            } onEnd: {
                isImporting = false
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
