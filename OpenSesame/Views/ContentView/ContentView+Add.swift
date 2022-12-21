//
//  ContentView+Add.swift
//  ContentView+Add
//
//  Created by Ethan Lipnik on 8/22/21.
//

import SwiftUI

extension ContentView {
    func addItem() {
        withAnimation {
            isCreatingNewVault = true
            isNewVaultFocused = true
        }
    }

    func addItem(withName name: String) {
        do {
            let vault = Vault(context: viewContext)
            vault.name = name

            try viewContext.save()
        } catch {
            print(error)
        }
    }
}
