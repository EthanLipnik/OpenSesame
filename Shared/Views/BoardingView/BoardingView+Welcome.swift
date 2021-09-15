//
//  BoardingView+Welcome.swift
//  BoardingView+Welcome
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

extension BoardingView {
    struct WelcomeView: View {
        @Binding var selectedIndex: Int
        
        var body: some View {
            VStack {
                Text("Welcome to OpenSesame")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.7)
                Spacer()
                VStack {
                    ItemView(message: "Vaults", image: "lock.square.stack.fill")
                    ItemView(message: "On-Device encryption", image: "key.fill")
                    ItemView(message: "iCloud syncing", image: "icloud.fill")
                    ItemView(message: "Two factor authentication", image: "lock.rectangle.on.rectangle.fill")
                    ItemView(message: "View on other devices", image: "laptopcomputer")
                }
                Spacer()
                Button {
                    withAnimation {
                        selectedIndex += 1
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            .padding(30)
        }
        
        func ItemView(message: String, image: String) -> some View {
            return ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Tertiary"))
                    .frame(height: 60)
                Label(message, systemImage: image)
                    .font(.title3.bold())
                    .allowsTightening(true)
                    .frame(maxWidth: 300)
            }
        }
    }
}
