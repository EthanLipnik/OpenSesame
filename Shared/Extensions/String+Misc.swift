//
//  String+Misc.swift
//  String+Misc
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

#if canImport(AppKit)
    import AppKit.NSPasteboard
#elseif canImport(UIKit)
    import UIKit.UIPasteboard
#endif

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }

    var asHexString: String {
        return unicodeScalars
            .filter { $0.isASCII }
            .map { String(format: "%X", $0.value) }
            .joined()
    }

    var withHTTPIfNeeded: String {
        var urlStr = self

        if !urlStr.hasPrefix("http://"), !urlStr.hasPrefix("https://") {
            urlStr = "https://" + self
        }

        return urlStr
    }

    var withWWWIfNeeded: String {
        var urlStr = self

        if !urlStr.hasPrefix("https://www.") || !urlStr.hasPrefix("http://www.") {
            urlStr = "https://www." + self
        } else if !urlStr.hasPrefix("www.") {
            urlStr = "www." + self
        }

        return urlStr
    }

    var removeHTTP: String {
        var urlStr = self

        if urlStr.hasPrefix("https://") {
            for _ in 0 ..< 8 {
                urlStr.removeFirst()
            }
        } else if urlStr.hasPrefix("http://") {
            for _ in 0 ..< 7 {
                urlStr.removeFirst()
            }
        }

        return urlStr
    }

    var removeWWW: String {
        var urlStr = self

        if urlStr.hasPrefix("www.") {
            for _ in 0 ..< 4 {
                urlStr.removeFirst()
            }
        }

        return urlStr
    }

    func addElipsis(platformSpecific: Bool = false) -> String {
        if platformSpecific {
            #if os(macOS)
                return self + "..."
            #else
                return self
            #endif
        }
        return self + "..."
    }

    func copyToPasteboard() {
        #if os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(self, forType: .string)
        #else
            let pasteboard = UIPasteboard.general
            pasteboard.string = self
        #endif
    }

    func contains(_ string: String, caseInsentive: Bool) -> Bool {
        if caseInsentive {
            return lowercased().contains(string.lowercased())
        }
        return contains(string)
    }
}
