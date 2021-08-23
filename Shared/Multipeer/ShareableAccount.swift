//
//  ShareableAccount.swift
//  ShareableAccount
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

struct ShareableAccount: Codable {
    var domain: String
    var dateAdded: Date = Date()
    var lastModified: Date?
    var password: String
    var username: String
    var url: String
}
