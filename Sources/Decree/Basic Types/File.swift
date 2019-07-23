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
    public init(name: String, content: Data, type: ContentType = .binary) {
        self.name = name
        self.content = content
        self.type = type
    }
}
