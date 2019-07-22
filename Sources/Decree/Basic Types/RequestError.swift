//
//  RequestError.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

public enum RequestError: Error {
    case encoding(Encodable, EncodingError)
    case unauthorized

    case custom(String)
}

extension RequestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .custom(let message):
            return message
        case .encoding(let value, _):
            return "Error encoding \(value)"
        case .unauthorized:
            return "Unauthorized"
        }
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
