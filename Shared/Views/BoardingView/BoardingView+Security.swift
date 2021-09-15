//
//  BoardingView+Security.swift
//  BoardingView+Security
//
//  Created by Ethan Lipnik on 9/13/21.
//

import SwiftUI

extension BoardingView {
    struct SecurityView: View {
        @Binding var selectedIndex: Int
        
        var body: some View {
            VStack {
                Text("Security")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "laptopcomputer.and.iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image(systemName: "arrow.left.arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image(systemName: "lock.square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxWidth: 300)
                Text("Sensitive information is encrypted and decrypted on-device only. This means that only you can read your data.")
                    .foregroundColor(Color.secondary)
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
    }
}
