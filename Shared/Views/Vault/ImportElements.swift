//
//  ImportElements.swift
//  ImportElements
//
//  Created by Ethan Lipnik on 9/12/21.
//

import SwiftUI

struct ImportButtons: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var appFormat: AppFormat = .browser
    
    @State private var shouldAuthenticate: Bool = false
    
    let completion: (AppFormat) -> Void
    
    var body: some View {
        Menu {
            Button {
                completion(.browser)
            } label: {
                Label("Web Browser", systemImage: "globe")
            }
            
            Divider()
            Button("1Password") {
                completion(.onePassword)
            }
            
            Button("Bitwarden") {
                completion(.bitwarden)
            }
        } label: {
            Label("Import", systemImage: "tray.and.arrow.down.fill")
        }
    }
}
