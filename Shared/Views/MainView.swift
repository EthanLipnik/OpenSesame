//
//  MainView.swift
//  MainView
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI
import KeychainAccess

struct MainView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Variables
    @Binding var isLocked: Bool
    @Binding var shouldHideApp: Bool
    
    @Binding var isImportingPasswords: Bool
    @Binding var shouldExportPasswords: Bool
    @Binding var isExportingPasswords: Bool
    
    // MARK: - View
    var body: some View {
        ZStack {
            // MARK: - ContentView
            /// ContentView is the main page that displays the vaults. Only gets initialized during login to prevent any peeping.
            if !isLocked {
                ContentView(isLocked: $isLocked)
                    .environment(\.managedObjectContext, viewContext)
                    .opacity(isLocked ? 0 : 1)
                    .blur(radius: isLocked ? 15 : 0)
                    .transition(.opacity)
                    .animation(.default, value: isLocked)
            }
            
            // MARK: - LockView
            LockView(isLocked: $isLocked) { // Unlock function
                isLocked = false
            }
            .environment(\.managedObjectContext, viewContext)
            .opacity(isLocked ? 1 : 0)
            .blur(radius: isLocked ? 0 : 25)
            .allowsHitTesting(isLocked) // Prevent lock screen from being interacted with even though it's in the foreground.
            .animation(.default, value: isLocked)
        }
#if os(macOS)
        .blur(radius: shouldHideApp ? 25 : 0)
#endif
        .animation(.default, value: shouldHideApp)
        
        // MARK: - ImportView
        .sheet(isPresented: $isImportingPasswords) {
            ImportView()
                .environment(\.managedObjectContext, viewContext)
        }
        
        // MARK: - ExportView
        .confirmationDialog("You are about to export your passwords unencrypted. Do not share this file!", isPresented: $shouldExportPasswords, actions: {
            Button("Export", role: .destructive) {
                self.isExportingPasswords = true
            }
            
            Button("Cancel", role: .cancel) { }.keyboardShortcut(.defaultAction)
        })
        .sheet(isPresented: $isExportingPasswords, onDismiss: {
            shouldExportPasswords = false
        }) {
            ExportView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isLocked: .constant(true), shouldHideApp: .constant(false), isImportingPasswords: .constant(false), shouldExportPasswords: .constant(false), isExportingPasswords: .constant(false))
    }
}
