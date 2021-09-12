//
//  ExportFile.swift
//  ExportFile
//
//  Created by Ethan Lipnik on 9/12/21.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct ExportFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.plainText, UTType.json, UTType.commaSeparatedText]

    // by default our document is empty
    var text = ""
    let format: FileFormat

    // a simple initializer that creates new, empty documents
    init(_ initialText: String = "", format: FileFormat) {
        text = initialText
        self.format = format
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
        format = .json
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
