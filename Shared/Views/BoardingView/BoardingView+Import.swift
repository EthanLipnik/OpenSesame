//
//  BoardingView+Import.swift
//  BoardingView+Import
//
//  Created by Ethan Lipnik on 9/14/21.
//

import SwiftUI

extension BoardingView {
    struct ImportView: View {
        @Environment(\.managedObjectContext) var viewContext
        
        @Binding var selectedIndex: Int
        
        @State private var isImporting: Bool = false
        @State private var importAppFormat: AppFormat = .browser
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Import")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Spacer()
                Image(systemName: "tray.and.arrow.down.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 30)
                Text("Import your existing accounts from another app or service.")
                    .foregroundColor(Color.secondary)
                Spacer()
                VStack {
                    Button {
                        UserDefaults.standard.set(true, forKey: "didShowBoardingScreen")
                    } label: {
                        Text("Not now")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    ImportButtons(shouldHaveImageLabel: false, isBold: true) { appFormat in
                        importAppFormat = appFormat
                        isImporting = true
                    }
                    .environment(\.managedObjectContext, viewContext)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: 300)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(30)
            .sheet(isPresented: $isImporting) {
#if os(macOS)
                ImportView(importManager: ImportManager(appFormat: importAppFormat))
                    .environment(\.managedObjectContext, viewContext)
#else
                NavigationView {
                    OpenSesame.ImportView(importManager: ImportManager(appFormat: importAppFormat))
                        .environment(\.managedObjectContext, viewContext)
                        .navigationTitle("Import")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(.stack)
                .interactiveDismissDisabled()
#endif
            }
        }
    }
}
