//
//  BoardingView+Sync.swift
//  BoardingView+Sync
//
//  Created by Ethan Lipnik on 9/14/21.
//

import SwiftUI

extension BoardingView {
    struct SyncView: View {
        @Binding var selectedIndex: Int
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Sync")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                Image(systemName: "lock.icloud.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 30)
                Text("Sync with iCloud securely. Have your accounts and cards on all your devices with ease.")
                    .foregroundColor(Color.secondary)
                Spacer()
                VStack {
                    Button {
                        UserSettings.default.shouldSyncWithiCloud = false
                        
                        withAnimation {
                            selectedIndex += 1
                        }
                    } label: {
                        Text("Do not sync")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    Button {
                        withAnimation {
                            selectedIndex += 1
                        }
                    } label: {
                        Text("Sync with iCloud")
                            .frame(maxWidth: 300)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!PersistenceController.isICloudContainerAvailable())
                }
            }
            .padding(30)
        }
    }
}
