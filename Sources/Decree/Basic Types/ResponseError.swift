//
//  ResponseError.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

public enum ResponseError: Error {
    case noResponse
    case missingData
    case decoding(typeName: String, DecodingError)
    case parsing(message: String)
    case parsed(AnyErrorResponse)
    case http(HTTPStatus)

    case custom(String)
}

extension ResponseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noResponse:
            return "No response returned"
        case .missingData:
            return "No data returned"
        case .decoding(let typeName, _):
            return "Error decoding \(typeName)"
        case .parsed(let parsed):
            return parsed.message
        case .parsing(let message):
            return "Error parsing response: \(message)"
        case .http(let status):
            switch status {
            case .other(let other):
                return "Unrecognized failure HTTP status: \(other)"
            default:
                return "\(status.rawValue) \(status.description)"
            }
        case .custom(let message):
            return message
        }
    }
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
