//
//  EncryptedAccountDocument.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/23/21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct EncryptedAccountDocument: FileDocument, Codable {
    var domain: String
    var website: String
    var username: String
    var password: Data?

    init(domain: String = "", website: String = "", username: String = "", password: Data?) {
        self.domain = domain
        self.website = website
        self.username = username
        self.password = password
    }

    enum CodingKeys: CodingKey {
        case domain
        case website
        case username
        case password
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        domain = try container.decode(String.self, forKey: .domain)
        website = try container.decode(String.self, forKey: .website)
        username = try container.decode(String.self, forKey: .username)
        password = Data(base64Encoded: try container.decode(String.self, forKey: .password))
    }

    init(_ account: Account, password: String) throws {
        domain = account.domain ?? ""
        website = account.url ?? ""
        username = account.username ?? ""

        guard let encryptionKey = CryptoSecurityService.generateKey(fromString: password),
              let password = try CryptoSecurityService.encrypt(
                  password,
                  encryptionKey: encryptionKey
              )
        else { throw CocoaError(.coderInvalidValue) }

        self.password = password
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self = try JSONDecoder().decode(EncryptedAccountDocument.self, from: data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(domain, forKey: .domain)
        try container.encode(website, forKey: .website)
        try container.encode(username, forKey: .username)
        if let password {
            try container.encode(password.base64EncodedString(), forKey: .password)
        }
    }

    static var readableContentTypes: [UTType] { [.encryptedAccountDocument] }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)

        return .init(regularFileWithContents: data)
    }
}
