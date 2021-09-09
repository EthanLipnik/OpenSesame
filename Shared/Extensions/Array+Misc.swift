//
//  Array+Misc.swift
//  Array+Misc
//
//  Created by Ethan Lipnik on 9/9/21.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
