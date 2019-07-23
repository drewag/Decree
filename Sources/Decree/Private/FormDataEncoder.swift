//
//  FormDataEncoder.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

public struct FormDataEncoder {
    static let boundary = "__DECREE_BOUNDARY__"

    static func encode(_ values: [(String,KeyValueEncoder.Value)]) -> Data {
        var body = Data()
        let newLine = "\r\n".data(using: .utf8)!

        for (key, value) in values {
            if !body.isEmpty {
                body += newLine
            }
            body += "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\""
                .data(using: .utf8) ?? Data()
            switch value {
            case .string(let string):
                body += newLine + newLine
                body += string.data(using: .utf8) ?? Data()
            case .bool(let bool):
                body += newLine + newLine
                body += (bool ? "true" : "false").data(using: .utf8) ?? Data()
            case .none:
                body += newLine + newLine
            case .data(let data):
                body += newLine + newLine
                body += data
            case .file(let file):
                body += "; filename=\"\(file.name)\"\r\nContent-Type: \(file.type.rawValue)\r\n\r\n"
                    .data(using: .utf8) ?? Data()
                body += file.content
            }
        }

        if !body.isEmpty, let end = "--\(boundary)--".data(using: .utf8) {
            body.append(end)
        }

        return body
    }
}
