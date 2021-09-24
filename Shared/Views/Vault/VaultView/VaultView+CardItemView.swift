//
//  VaultView+CardItemView.swift
//  VaultView+CardItemView
//
//  Created by Ethan Lipnik on 8/30/21.
//

import SwiftUI

extension VaultView {
    struct CardItemView: View {
        @EnvironmentObject var viewModel: ViewModel
        
        let card: Card
        
        var body: some View {
            NavigationLink(tag: .init(card), selection: $viewModel.selectedItem) {
                CardView(card: card)
            } label: {
                Label(card.name!, systemImage: "creditcard.fill")
            }
        }
    }
}
