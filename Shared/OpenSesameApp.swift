//
//  OpenSesameApp.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI

@main
struct OpenSesameApp: SwiftUI.App {
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Services
    let persistenceController = PersistenceController.shared
    
    // MARK: - Variables
    @State var isLocked: Bool = true
    @State var shouldHideApp: Bool = false
    
    @State var isImportingPasswords: Bool = false
    @State var shouldExportPasswords: Bool = false
    @State var isExportingPasswords: Bool = false
    
    // MARK: - View
    var body: some Scene {
        WindowGroup {
            // MARK: - MainView
            MainView(isLocked: $isLocked,
                     isImportingPasswords: $isImportingPasswords,
                     shouldExportPasswords: $shouldExportPasswords,
                     isExportingPasswords: $isExportingPasswords)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .overlay(shouldHideApp ? Rectangle().fill(Material.ultraThin).ignoresSafeArea(.all, edges: .all) : nil)
                .animation(.default, value: shouldHideApp)
                .onAppear {
                    UserSettings.default.updateColorScheme(shouldAnimate: false)
                }
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        .commands {
            SidebarCommands()
            ToolbarCommands()
            
            CommandGroup(replacing: .newItem) {
                Group {
                    Link("New Vault...", destination: URL(string: "openSesame://new?type=vault")!)
                        .keyboardShortcut("n")
                    Link("New Account...", destination: URL(string: "openSesame://new?type=account")!)
                        .keyboardShortcut("n", modifiers: [.shift, .command])
                    Link("New Card...", destination: URL(string: "openSesame://new?type=card")!)
                        .keyboardShortcut("n", modifiers: [.shift, .option, .command])
                }
#if os(macOS)
                .disabled(isLocked)
#endif
            }
            
            CommandGroup(after: .newItem) {
                Divider()
                
                Button("Unlock with Biometrics...") {
                    
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
#if os(macOS)
                .disabled(!isLocked)
#endif
                
                Button("Lock") {
                    if !isLocked {
                        isLocked = true
                    }
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
#if os(macOS)
                .disabled(isLocked)
#endif
                
                Divider()
                
                Group {
                    Button("Import...") {
                        isImportingPasswords.toggle()
                    }
                    
                    Menu("Export") {
                        Button("CSV...") {
                            shouldExportPasswords = true
                        }
                        
                        Button("JSON...") {
                            
                        }.disabled(true)
                    }
                }
                .disabled(isLocked)
            }
        }
        .onChange(of: scenePhase) { phase in
            withAnimation {
                switch phase {
                case .active:
                    print("App is active")
                    shouldHideApp = false
                    break
                case .background:
                    print("App is in background")
                    isLocked = true
                    shouldHideApp = true
                    CryptoSecurityService.encryptionKey = nil
                case .inactive:
                    shouldHideApp = true
                @unknown default:
                    break
                }
            }
        }
        
        // MARK: - Settings
        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #endif
    }
}
