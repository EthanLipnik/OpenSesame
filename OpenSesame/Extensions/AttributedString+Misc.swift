//
//  AttributedString+Misc.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

extension AttributedString {
    init(account: Account) {
        var string =
            AttributedString((
                (account.url?.isEmpty ?? true) ? nil : account.url?.removeHTTP
                    .removeWWW
            ) ?? account.domain ?? "Unknown website")
        if let domain = account.domain {
            if let match = string.range(of: domain, options: [.caseInsensitive, .diacriticInsensitive]) {
                string.foregroundColor = Color.secondary
                string[match].foregroundColor = Color("Label")
            }
        }

        self = string
    }
}
