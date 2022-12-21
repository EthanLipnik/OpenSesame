//
//  ExportElements.swift
//  ExportElements
//
//  Created by Ethan Lipnik on 9/12/21.
//

import Foundation
import SwiftUI

struct ExportButtons: View {
    @State
    private var appFormat: AppFormat = .browser
    @State
    private var fileFormat: FileFormat = .json
    @State
    private var isExporting: Bool = false

    @State
    private var exportFile: ExportFile?

    @State
    private var shouldAuthenticate: Bool = false

    let completion: (ExportFile) -> Void

    var body: some View {
        Menu {
            Menu {
                export(.browser)
            } label: {
                Label("Web Browser".addElipsis(platformSpecific: true), systemImage: "globe")
            }

            Divider()
            Menu("1Password".addElipsis(platformSpecific: true)) {
                export(.onePassword)
            }

            Menu("Bitwarden".addElipsis(platformSpecific: true)) {
                export(.bitwarden)
            }
        } label: {
            Label(
                "Export".addElipsis(platformSpecific: true),
                systemImage: "tray.and.arrow.up.fill"
            )
        }
#if os(iOS)
        .halfSheet(isPresented: $shouldAuthenticate, supportsLargeView: false) {
            AuthenticationView(
                message: "You are exporting your passwords without any encryption. Do this at your own risk.",
                onSuccess: didAuthenticate
            )
        }
#endif
    }

    func didAuthenticate(_: String) {
        isExporting = false
        shouldAuthenticate = false

        completion(exportFile!)
    }

    func export(_ appFormat: AppFormat) -> some View {
        Group {
            Button("JSON".addElipsis(platformSpecific: true)) {
                do {
                    fileFormat = .json
                    exportFile = try ExportManager(vault: nil)
                        .export(fileFormat, appFormat: appFormat)
#if os(macOS)
                    completion(exportFile!)
#else
                    isExporting = true
                    shouldAuthenticate = true
#endif
                } catch {
                    print(error)
                }
            }

            Button("CSV".addElipsis(platformSpecific: true)) {
                do {
                    fileFormat = .csv
                    exportFile = try ExportManager(vault: nil)
                        .export(fileFormat, appFormat: appFormat)
#if os(macOS)
                    completion(exportFile!)
#else
                    isExporting = true
                    shouldAuthenticate = true
#endif
                } catch {
                    print(error)
                }
            }
        }
    }
}
