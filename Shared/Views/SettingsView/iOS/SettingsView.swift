//
//  SettingsView.swift
//  SettingsView
//
//  Created by Ethan Lipnik on 8/24/21.
//

import SwiftUI
import AuthenticationServices
import StoreKit
import KeychainAccess
import CoreData

struct SettingsView: View {
    let persistenceController = PersistenceController.shared
    
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var shouldNukeDatabase: Bool = false
    
    @State private var shouldResetBiometrics: Bool = false
    @State private var shouldAuthenticate: Bool = false
    
    @State private var authenticatedPassword: String = ""
    
    private let icons: [String] = ["Default", "Green", "Orange", "Purple", "Red", "Silver", "Space Gray"]
    
    @StateObject var userSettings = UserSettings.default
    
    var body: some View {
        let availableBiometrics = UserAuthenticationService.availableBiometrics()
        
        return Form {
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
                Toggle(isOn: $userSettings.shouldUseBiometrics) {
                    let image: String = {
                        if availableBiometrics.contains(.faceID) {
                            return "faceid"
                        } else if availableBiometrics.contains(.touchID) {
                            return "touchid"
                        } else if availableBiometrics.contains(.watch) {
                            return "lock.applewatch"
                        } else {
                            return "faceid"
                        }
                    }()
                    Label("Allow Biometrics", systemImage: image)
                }
                .tint(.accentColor)
                .disabled(availableBiometrics.isEmpty)
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
                        if state.isEnabled {
                            ASCredentialIdentityStore.shared.removeAllCredentialIdentities { success, error in
                                let accountsFetch = NSFetchRequest<Account>(entityName: "Account")
                                
                                do {
                                    let accounts = try persistenceController.container.viewContext.fetch(accountsFetch)
                                    let domainIdentifers = accounts.map({ ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: $0.domain!, type: .domain),
                                                                                                       user: $0.username!,
                                                                                                       recordIdentifier: nil) })
                                    
                                    
                                    ASCredentialIdentityStore.shared.saveCredentialIdentities(domainIdentifers, completion: {(_,error) -> Void in
                                        print(error?.localizedDescription ?? "No errors in saving credentials")
                                    })
                                } catch {
                                    print(error)
                                }
                            }
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
        .sheet(isPresented: $isImporting) {
            NavigationView {
                ImportView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .navigationTitle("Import")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            .interactiveDismissDisabled()
        }
        .onChange(of: userSettings.shouldUseBiometrics) { value in
            if value {
                shouldResetBiometrics = true
                shouldAuthenticate = true
            }
        }
        .halfSheet(showSheet: $shouldAuthenticate, supportsLargeView: false) {
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
                GroupBox {
                    HStack {
                        SecureField("Master password", text: $authenticatedPassword, onCommit: {
                            guard !authenticatedPassword.isEmpty, runEncryptionTest(authenticatedPassword) else { return }
                            if shouldResetBiometrics {
                                try? LockView.updateBiometrics(authenticatedPassword)
                                shouldResetBiometrics = false
                            }
                            
                            shouldAuthenticate = false
                        })
                            .textFieldStyle(.plain)
                            .frame(maxWidth: 400)
                        Button {
                            guard !authenticatedPassword.isEmpty, runEncryptionTest(authenticatedPassword) else { return }
                            if shouldResetBiometrics {
                                try? LockView.updateBiometrics(authenticatedPassword)
                                shouldResetBiometrics = false
                            }
                            
                            shouldAuthenticate = false
                        } label: {
                            Image(systemName: "key.fill")
                        }
                    }
                }
            }.padding()
        } onEnd: {
            if shouldResetBiometrics {
                shouldResetBiometrics = false
                withAnimation {
                    userSettings.shouldUseBiometrics = false
                }
            }
        }
    }
    
    func runEncryptionTest(_ password: String) -> Bool {
        if let test = try? Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
            .synchronizable(true)
            .getData("encryptionTest") {
            
            return (try? CryptoSecurityService.decrypt(test, encryptionKey: CryptoSecurityService.generateKey(fromString: password))) != nil
        } else {
            return false
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
