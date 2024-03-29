//
//  Document.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/23/21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class Document: Codable {
    class func data(object: some Encodable) throws -> Data {
        try JSONEncoder().encode(object)
    }

    @discardableResult
    class func save(
        _ url: URL? = nil,
        object: some Encodable,
        fileName: String,
        fileExtension: String
    ) throws -> URL {
        var fileURL: URL! = url

        if url == nil {
            let directory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
            if FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
            fileURL = directory.appendingPathComponent(fileName + "." + fileExtension)
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        try data(object: object).write(to: fileURL)

        return fileURL
    }
}

extension EncryptedAccountDocument {
    func data() throws -> Data {
        try Document.data(object: self)
    }

    @discardableResult
    func save(_ url: URL? = nil) throws -> URL {
        try Document.save(url, object: self, fileName: "Encrypted Account", fileExtension: "osae")
    }
}

extension AccountDocument {
    func data() throws -> Data {
        try Document.data(object: self)
    }

    @discardableResult
    func save(_ url: URL? = nil) throws -> URL {
        try Document.save(url, object: self, fileName: "Account", fileExtension: "osa")
    }
}

extension CardDocument {
    func data() throws -> Data {
        try Document.data(object: self)
    }

    @discardableResult
    func save(_ url: URL? = nil) throws -> URL {
        try Document.save(url, object: self, fileName: "Card", fileExtension: "osc")
    }
}

extension NoteDocument {
    func data() throws -> Data {
        try Document.data(object: self)
    }

    @discardableResult
    func save(_ url: URL? = nil) throws -> URL {
        try Document.save(url, object: self, fileName: "Note", fileExtension: "osn")
    }
}

extension UTType {
    static var accountDocument: UTType {
        UTType(importedAs: "com.opensesame.account")
    }

    static var encryptedAccountDocument: UTType {
        UTType(importedAs: "com.opensesame.account-encrypted")
    }

    static var cardDocument: UTType {
        UTType(importedAs: "com.opensesame.card")
    }

    static var noteDocument: UTType {
        UTType(importedAs: "com.opensesame.note")
    }
}
