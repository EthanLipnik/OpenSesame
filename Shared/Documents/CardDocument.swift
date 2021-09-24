//
//  CardDocument.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/24/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct CardDocument: FileDocument, Codable {
    
    // MARK: - Variables
    var expirationDate: String
    var holder: String
    var name: String
    var number: String
    
    // MARK: - Inits
    init(expirationDate: String, holder: String, name: String, number: String) {
        self.expirationDate = expirationDate
        self.holder = holder
        self.name = name
        self.number = number
    }
    
    enum CodingKeys: CodingKey {
        case expirationDate
        case holder
        case name
        case number
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.expirationDate = try container.decode(String.self, forKey: .expirationDate)
        self.holder = try container.decode(String.self, forKey: .holder)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(String.self, forKey: .number)
    }
    
    init(_ card: Card) throws {
        self.expirationDate = card.expirationDate ?? ""
        self.holder = card.holder ?? ""
        self.name = card.name ?? ""
        self.number = try CryptoSecurityService.decrypt(card.number!) ?? ""
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try JSONDecoder().decode(CardDocument.self, from: data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expirationDate, forKey: .expirationDate)
        try container.encode(holder, forKey: .holder)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
    }
    
    static var readableContentTypes: [UTType] { [.cardDocument] }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        
        return .init(regularFileWithContents: data)
    }
}
