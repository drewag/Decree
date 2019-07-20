//
//  RequestError.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

public enum RequestError: Error {
    case noResponse
    case missingData
    case decoding(typeName: String, DecodingError)
    case encoding(Encodable, EncodingError)
    case parsed(AnyErrorResponse)

    case custom(String)
}

extension RequestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noResponse:
            return "No response returned"
        case .missingData:
            return "No data returned"
        case .custom(let message):
            return message
        case .decoding(let typeName, _):
            return "Error decoding \(typeName)"
        case .encoding(let value, _):
            return "Error encoding \(value)"
        case .parsed(let parsed):
            return parsed.message
        }
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
