//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI
import AuthenticationServices
import StoreKit

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var shouldNukeDatabase: Bool = false
    
    private let icons: [String] = ["Default", "Green", "Orange", "Purple", "Red", "Silver", "Space Gray"]
    
    @StateObject var userSettings = UserSettings.default
    
    var body: some View {
        Form {

            Section {
                Toggle(isOn: $userSettings.shouldLoadFavicon) {
                    Label("Load Favicons", systemImage: "photo.fill")
                }
                .tint(.accentColor)
                Toggle(isOn: $userSettings.shouldShowFaviconInList) {
                    Label("Show Favicons in List", systemImage: "list.dash")
                }
                .tint(.accentColor)
                .disabled(!userSettings.shouldLoadFavicon)
                .animation(.default, value: userSettings.shouldLoadFavicon)
                Toggle(isOn: $userSettings.shouldSyncWithiCloud) {
                    Label("Sync with iCloud", systemImage: "icloud.fill")
                }
                .tint(.accentColor)
                .disabled(!PersistenceController.isICloudContainerAvailable())
            } header: {
                Text("General")
            } footer: {
                Text(PersistenceController.isICloudContainerAvailable() ? "Sync with all your devices securely." : "You are not signed in with iCloud or disabled OpenSesame in iCloud settings.")
            }
            
            Section("Passwords") {
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
            }
            
            Section("Appearance") {
                HStack {
                    Label("Color Scheme", systemImage: "circle.fill")
                    Spacer()
                    Picker("Color Scheme", selection: $userSettings.colorScheme) {
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
                        Text("30 seconds")
                            .tag(1)
                        Text("1 minute")
                            .tag(2)
                        Text("3 minutes")
                            .tag(3)
                        Text("4 minutes")
                            .tag(4)
                        Text("5 minutes")
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
                Button {
                    if let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .compactMap({$0 as? UIWindowScene})
                        .first {
                        
                        SKStoreReviewController.requestReview(in: keyWindow)
                    }
                } label: {
                    Label("Rate OpenSesame", systemImage: "star.fill")
                }
            }
            Section {
                Link(destination: URL(string: "https://opensesamemanager.github.com/Website")!) {
                    Label("Website", systemImage: "globe")
                }
                Link(destination: URL(string: "https://github.com/OpenSesameManager/OpenSesame")!) {
                    Label("Source Code", systemImage: "chevron.left.slash.chevron.right")
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
                    shouldNukeDatabase.toggle()
                } label: {
                    Label("Nuke Database", systemImage: "trash.fill")
                }
                .confirmationDialog("Would you like to just nuke the local database or include the iCloud database as well?", isPresented: $shouldNukeDatabase) {
                    Button("Local", role: .destructive) {
                    }
                    
                    Button("Local + iCloud", role: .destructive) {
                    }
                    
                    Button("Cancel", role: .cancel) {
                        shouldNukeDatabase = false
                    }
                    .keyboardShortcut(.defaultAction)
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
