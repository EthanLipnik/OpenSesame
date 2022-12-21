//
//  SettingsView+MenuBarView.swift
//  SettingsView+MenuBarView
//
//  Created by Ethan Lipnik on 8/22/21.
//

#if os(macOS)
import SwiftUI

extension SettingsView {
    struct MenuBarView: View {
        // MARK: - Variables

        @State
        var shouldShowInMenuBar: Bool = false
        @State
        var shouldOpenOnStartup: Bool = false
        @State
        var shouldKeepAppInDock: Bool = true

        // MARK: - View

        var body: some View {
            VStack(spacing: 20) {
                systemView
            }
        }

        // MARK: - SystemView

        var systemView: some View {
            VStack(spacing: 20) {
                Toggle("Show in Menu Bar", isOn: $shouldShowInMenuBar)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack {
                    Text("System")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    GroupBox {
                        VStack(alignment: .leading) {
                            Toggle("Open on Startup", isOn: $shouldOpenOnStartup)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Toggle("Keep app in dock", isOn: $shouldKeepAppInDock)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.padding(5)
                    }
                }
                .disabled(!shouldShowInMenuBar)
            }
        }
    }
}
#endif
