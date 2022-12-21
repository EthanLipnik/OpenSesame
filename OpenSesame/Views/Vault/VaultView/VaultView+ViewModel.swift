//
//  VaultView+ViewModel.swift
//  VaultView+ViewModel
//
//  Created by Ethan Lipnik on 8/30/21.
//

import Combine
import Foundation

extension VaultView {
    class ViewModel: ObservableObject {
        @Published
        var selectedItem: Item?

        @Published
        var selectedItems: Set<Item> = []
    }
}
