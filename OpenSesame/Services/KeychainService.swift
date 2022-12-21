//
//  KeychainService.swift
//  KeychainService
//
//  Created by Robert Shand on 2021-09-11.
//

import Foundation
import KeychainAccess

typealias OpenSesameKeychain = Keychain

extension Keychain {
    convenience init() {
        self.init(
            service: OpenSesameConfig.bundleIdentifer,
            accessGroup: "\(OpenSesameConfig.teamIdentifer).OpenSesame"
        )
    }
}
