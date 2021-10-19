//
//  OpenSesameApp.swift
//  Shared
//
//  Created by Ethan Lipnik on 8/18/21.
//

import SwiftUI

@main
struct OpenSesameApp: App {
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Services
    let persistenceController = PersistenceController.shared
    
    // MARK: - Variables
    @State var isLocked: Bool = true
    @State var shouldHideApp: Bool = false
    
    @State var isExportingPasswords: Bool = false
    @State var exportFile: ExportFile? = nil
    
    @State var importAppFormat: AppFormat? = nil
    
    @State var lastOpenedDate: Date? = nil
    
    // MARK: - View
    var body: some Scene {
        WindowGroup {
            // MARK: - MainView
            MainView(isLocked: $isLocked)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .overlay(shouldHideApp && !isLocked && UserSettings.default.shouldHideApp ? Rectangle().fill(Material.ultraThin).ignoresSafeArea(.all, edges: .all) : nil)
                .animation(.default, value: shouldHideApp)
                .onAppear {
                    UserSettings.default.updateColorScheme(shouldAnimate: false)
                }
                .fileExporter(isPresented: $isExportingPasswords, document: exportFile, contentType: (exportFile?.format ?? .json) == .csv ? .commaSeparatedText : .json, defaultFilename: "Passwords") { result in
                    switch result {
                    case .success(let url):
                        print("Exported at path", url.path)
                    case .failure(let error):
                        print(error)
                    }
                }
                .sheet(item: $importAppFormat) { format in
#if os(iOS)
                    NavigationView {
                        ImportView(importManager: ImportManager(appFormat: format))
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .navigationTitle("Import")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(.stack)
                    .interactiveDismissDisabled()
#else
                    ImportView(importManager: ImportManager(appFormat: format))
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
#endif
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
                    ImportButtons { appFormat in
                        guard !isLocked else { return }
                        self.importAppFormat = appFormat
                    }
                    ExportButtons { exportFile in
                        guard !isLocked else { return }
                        self.exportFile = exportFile
                        self.isExportingPasswords = true
                    }
                }
#if os(macOS)
                .disabled(isLocked)
#endif
            }
            
#if os(macOS)
            CommandGroup(replacing: .help) {
                Link("OpenSesame Help", destination: URL(string: "https://github.com/OpenSesameManager/OpenSesame/issues/new/choose")!)
            }
#endif
        }
        .onChange(of: scenePhase) { phase in
            withAnimation {
                switch phase {
                case .active:
                    print("App is active")
                    shouldHideApp = false
                    
                    if let lastOpenedDate = lastOpenedDate {
                        let timeInterval = Date().timeIntervalSince(lastOpenedDate)
                        switch UserSettings.default.autoLockTimer {
                        case 1:
                            if timeInterval > 30 {
                                isLocked = true
                                CryptoSecurityService.encryptionKey = nil
                            }
                        case 2:
                            if timeInterval > 60 {
                                isLocked = true
                                CryptoSecurityService.encryptionKey = nil
                            }
                        case 3:
                            if timeInterval > 180 {
                                isLocked = true
                                CryptoSecurityService.encryptionKey = nil
                            }
                        case 4:
                            if timeInterval > 240 {
                                isLocked = true
                                CryptoSecurityService.encryptionKey = nil
                            }
                        case 5:
                            if timeInterval > 300 {
                                isLocked = true
                                CryptoSecurityService.encryptionKey = nil
                            }
                        default:
                            break
                        }
                    }
                    
                    break
                case .background:
                    print("App is in background")
                    
                    lastOpenedDate = Date()
                    
                    if UserSettings.default.autoLockTimer == 0 {
                        isLocked = true
                        CryptoSecurityService.encryptionKey = nil
                    }
                    shouldHideApp = true
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
    
#if os(iOS)
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
#endif
    
    static var isMac: Bool {
#if os(macOS)
        return true
#else
        return false
#endif
    }
}
