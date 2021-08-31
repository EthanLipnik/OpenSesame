//
//  VaultView+ViewModel.swift
//  VaultView+ViewModel
//
//  Created by Ethan Lipnik on 8/30/21.
//

import Foundation
import Combine

extension VaultView {
    class ViewModel: ObservableObject {
        @Published var selectedItem: Item? = nil
        
        @Published var selectedItems: Set<Item> = []
    }
}
