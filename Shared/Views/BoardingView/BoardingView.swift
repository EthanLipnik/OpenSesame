//
//  BoardingView.swift
//  BoardingView
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

struct BoardingView: View {
    @Binding var encryptionTestDoesntExist: Bool
    @State private var selectedIndex: Int = 0
    
    let masterPasswordCompletion: (String) -> Void
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            WelcomeView(selectedIndex: $selectedIndex)
                .tag(0)
            SecurityView(selectedIndex: $selectedIndex)
                .tag(1)
            SetupView(encryptionTestDoesntExist: $encryptionTestDoesntExist, selectedIndex: $selectedIndex, completion: masterPasswordCompletion)
                .tag(2)
            CardView(selectedIndex: $selectedIndex)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(.systemGroupedBackground))
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
