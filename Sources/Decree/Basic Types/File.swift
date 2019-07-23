//
//  File.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

/// A file to be used in endpoint inputs
public struct File: Encodable, Equatable {
    public enum ContentType: String, Encodable {
        case json = "application/json"
        case xml = "text/xml"
        case binary = "application/octet-stream"
        case text = "text/plain"
    }

    public let name: String
    public let content: Data
    public let type: ContentType

    /// Create a new file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - content: the content of the file
    ///     - type: the type of content
    public init(name: String, content: Data, type: ContentType) {
        self.name = name
        self.content = content
        self.type = type
    }

    /// Create a new text file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - text: the content of the file
    public init(name: String, text: String) {
        self.init(name: name, content: text.data(using: .utf8) ?? Data(), type: .text)
    }

    /// Create a new binary file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - binary: the content of the file
    public init(name: String, binary: Data) {
        self.init(name: name, content: binary, type: .binary)
    }

    /// Create a new XML file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - xml: the XML of the file
    public init(name: String, xml: String) {
        self.init(name: name, content: xml.data(using: .utf8) ?? Data(), type: .xml)
    }

    /// Create a new JSON file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - json: the JSON of the file
    public init(name: String, json: String) {
        self.init(name: name, content: json.data(using: .utf8) ?? Data(), type: .json)
    }

    /// Create a new json file
    ///
    /// - Parameters:
    ///     - name: the name of the file (including extension)
    ///     - object: the object to encode as JSON
    public init<E: Encodable>(name: String, jsonObject: E) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(jsonObject)
        self.init(name: name, content: data, type: .json)
    }
}
