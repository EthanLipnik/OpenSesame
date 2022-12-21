//
//  NoteDocument.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/24/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct NoteDocument: FileDocument, Codable {
    // MARK: - Variables

    var name: String
    var color: Int
    var body: String

    // MARK: - Inits

    init(name: String, color: Int, body: String) {
        self.name = name
        self.color = color
        self.body = body
    }

    enum CodingKeys: CodingKey {
        case name
        case color
        case body
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        color = try container.decode(Int.self, forKey: .color)
        body = try container.decode(String.self, forKey: .body)
    }

    init(_ note: Note) throws {
        name = note.name ?? ""
        color = Int(note.color)
        body = try CryptoSecurityService.decrypt(note.body!) ?? ""
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self = try JSONDecoder().decode(NoteDocument.self, from: data)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(body, forKey: .body)
    }

    static var readableContentTypes: [UTType] { [.noteDocument] }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)

        return .init(regularFileWithContents: data)
    }
}
