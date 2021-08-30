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
    let multipeer = MultipeerService.shared
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
                     shouldHideApp: $shouldHideApp,
                     isImportingPasswords: $isImportingPasswords,
                     shouldExportPasswords: $shouldExportPasswords,
                     isExportingPasswords: $isExportingPasswords)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
                }.disabled(isLocked)
            }
            
            CommandGroup(after: .newItem) {
                Divider()
                
                Button("Unlock with Biometrics...") {
                    
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
                .disabled(!isLocked)
                
                Button("Lock") {
                    isLocked = true
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                .disabled(isLocked)
                
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
                }.disabled(isLocked)
            }
        }
        .onChange(of: isLocked, perform: { isLocked in
            if !isLocked {
                multipeer.transceiver.resume()
            } else {
                multipeer.transceiver.stop()
            }
        })
        .onChange(of: scenePhase) { phase in
            withAnimation {
                switch phase {
                case .active:
                    print("App is active")
                    shouldHideApp = false
                    
                    if !isLocked {
                        multipeer.transceiver.resume()
                    }
                    break
                case .background:
                    print("App is in background")
                    isLocked = true
                    shouldHideApp = true
                case .inactive:
                    shouldHideApp = true
                    multipeer.transceiver.stop()
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
