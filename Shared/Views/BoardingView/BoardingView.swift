//
//  BoardingView.swift
//  BoardingView
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

struct BoardingView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var encryptionTestDoesntExist: Bool
    @State private var selectedIndex: Int = 0
    
    let masterPasswordCompletion: (String) -> Void
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            WelcomeView(selectedIndex: $selectedIndex)
                .tabItem {
                    Text("Welcome")
                }
                .tag(0)
            SecurityView(selectedIndex: $selectedIndex)
                .tabItem {
                    Text("Security")
                }
                .tag(1)
            SetupView(encryptionTestDoesntExist: $encryptionTestDoesntExist, selectedIndex: $selectedIndex, completion: masterPasswordCompletion)
                .tabItem {
                    Text("Setup")
                }
                .tag(2)
            SyncView(selectedIndex: $selectedIndex)
                .tabItem {
                    Text("Sync")
                }
                .tag(3)
            ImportView(selectedIndex: $selectedIndex)
                .tabItem {
                    Text("Import")
                }
                .tag(4)
            //            CardView(selectedIndex: $selectedIndex)
            //                .tabItem {
            //                    Text("Cards")
            //                }
            //                .tag(5
        }
#if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color("GroupedBackground"))
#else
        .padding()
#endif
        .onChange(of: selectedIndex) { newValue in
            if newValue > 2 && encryptionTestDoesntExist {
                withAnimation {
                    selectedIndex = 2
                }
            }
        }
    }
}

struct BoardingView_Previews: PreviewProvider {
    static var previews: some View {
        BoardingView(encryptionTestDoesntExist: .constant(true)) { _ in
            
        }
    }
}
