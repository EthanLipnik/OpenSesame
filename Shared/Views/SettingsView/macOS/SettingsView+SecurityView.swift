//
//  SettingsView+SecurityView.swift
//  SettingsView+SecurityView
//
//  Created by Ethan Lipnik on 9/8/21.
//

import SwiftUI

extension SettingsView {
    struct SecurityView: View {
        // MARK: - Environment
        @EnvironmentObject var userSettings: UserSettings
        
        // MARK: - View
        var body: some View {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    Text("Biometrics:")
                        .frame(width: 100, alignment: .trailing)
                    VStack(alignment: .leading) {
                        Toggle("Use Biometrics", isOn: $userSettings.shouldUseBiometrics)
                    }
                    Spacer()
                }
                HStack(alignment: .top) {
                    Text("Privacy:")
                        .frame(width: 100, alignment: .trailing)
                    VStack(alignment: .leading) {
                        Toggle("Hide When Minimizing App", isOn: $userSettings.shouldHideApp)
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
}
