//
//  AttributedString+Misc.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/15/21.
//

import SwiftUI

extension AttributedString {
    init(account: Account) {
        self = AttributedString(((account.url?.isEmpty ?? true) ? nil : account.url?.removeHTTP.removeWWW) ?? account.domain ?? "Unknown website")
        if let domain = account.domain {
            if let match = self.range(of: domain, options: [.caseInsensitive, .diacriticInsensitive]) {
                self.foregroundColor = Color.secondary
                self[match].foregroundColor = Color("Label")
            }
        }
    }
}
