//
//  TipJarView.swift
//  TipJarView
//
//  Created by Ethan Lipnik on 8/31/21.
//

import SwiftUI

struct TipJarView: View {
    // MARK: - View

    var body: some View {
#if os(iOS)
        ScrollView {
            content
                .frame(maxWidth: 600)
        }
#else
        content
#endif
    }

    var content: some View {
        GroupBox {
            // MARK: - Message

            Text(
                "**OpenSesame** is open source and completely free so anyone can use it.\n\nTips helps me develop and maintain this app to keep delivering quality feature updates.\n\nTips are never expected but are appreciated"
            )
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
#if os(iOS)
        NavigationView {
            TipJarView()
                .navigationTitle("Tip Jar")
        }
        .navigationViewStyle(.stack).previewInterfaceOrientation(.portrait)
#else
        TipJarView()
#endif
    }
}
