//
//  String+Misc.swift
//  String+Misc
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    var asHexString: String {
        return self
            .unicodeScalars
            .filter { $0.isASCII }
            .map { String(format: "%X", $0.value) }
            .joined()
    }
}
