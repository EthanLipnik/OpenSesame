//
//  VaultView+CardItemView.swift
//  VaultView+CardItemView
//
//  Created by Ethan Lipnik on 8/30/21.
//

import SwiftUI

extension VaultView {
    struct CardItemView: View {
        let card: Card
        @Binding var selectedCard: Card?
        
        var body: some View {
            NavigationLink(tag: card, selection: $selectedCard) {
                CardView(card: card)
            } label: {
                VStack(alignment: .leading) {
                    Text(card.name!)
                        .bold()
                        .lineLimit(1)
                    Text(card.holder!)
                        .foregroundColor(Color.secondary)
                        .lineLimit(1)
                        .blur(radius: CommandLine.arguments.contains("-marketing") ? 5 : 0)
                }
            }
        }
    }
}
