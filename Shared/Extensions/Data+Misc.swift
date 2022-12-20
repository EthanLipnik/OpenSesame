//
//  Data+Misc.swift
//  Data+Misc
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0 ..< len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i ..< j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }

    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
