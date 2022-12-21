//
//  SettingsView+SyncView.swift
//  SettingsView+SyncView
//
//  Created by Ethan Lipnik on 8/24/21.
//

#if os(macOS)
import AuthenticationServices
import SwiftUI

extension SettingsView {
    struct SyncView: View {
        let persistenceController = PersistenceController.shared

        @EnvironmentObject
        var userSettings: UserSettings

        var body: some View {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    Text("iCloud:")
                        .frame(width: 100, alignment: .trailing)
                    VStack(alignment: .leading) {
                        Toggle("Sync with iCloud", isOn: $userSettings.shouldSyncWithiCloud)
                            .disabled(!PersistenceController.isICloudContainerAvailable())
                        Text(
                            PersistenceController
                                .isICloudContainerAvailable() ?
                                "Sync with all your devices securely." :
                                "You are not signed in with iCloud or disabled OpenSesame in iCloud settings."
                        )
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.leading)
                    }
                    Spacer()
                }
            }.padding()
        }
    }
}
#endif
