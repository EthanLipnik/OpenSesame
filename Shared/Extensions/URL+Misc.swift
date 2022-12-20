//
//  URL+Misc.swift
//  URL+Misc
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

extension URL {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: absoluteString, options: [], range: NSRange(location: 0, length: absoluteString.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == absoluteString.utf16.count
        } else {
            return false
        }
    }
}
