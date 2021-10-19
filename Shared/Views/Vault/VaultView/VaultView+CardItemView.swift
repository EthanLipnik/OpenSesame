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
        var isPopover: Bool = false
        
        @State private var isPresenting: Bool = false
        
        var body: some View {
            Group {
                if isPopover {
                    Button {
                        isPresenting.toggle()
                    } label: {
                        content
                    }
                    .popover(isPresented: $isPresenting) {
                        NavigationView {
                            CardView(card: card)
                                .toolbar {
                                    ToolbarItem(placement: .navigation) {
                                        Button("Done") {
                                            isPresenting = false
                                        }
                                    }
                                }
                        }
                        .frame(minWidth: 400, minHeight: 325)
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(tag: .init(card), selection: $viewModel.selectedItem) {
                        CardView(card: card)
                    } label: {
                        content
                    }
                }
            }
        }
        
        var content: some View {
            Label(card.name!, systemImage: "creditcard.fill")
        }
    }
}
