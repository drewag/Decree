//
//  ResponseError.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

public enum ResponseError: Error {
    case noResponse
    case missingData
    case decoding(typeName: String, DecodingError)
    case encoding(Encodable, EncodingError)
    case parsed(AnyErrorResponse)

    case multipleChoices
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case temporaryRedirect

    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case requestEntityTooLarge
    case requestURITooLong
    case unsupportedMediaType
    case requestedRangeNotSatisfiable
    case expectationFailed

    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported

    case otherStatus(Int)

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
        case .encoding(let value, _):
            return "Error encoding \(value)"
        case .parsed(let parsed):
            return parsed.message

        case .multipleChoices:
            return "MULTIPLE CHOICES"
        case .movedPermanently:
            return "MOVED PERMANENTLY"
        case .found:
            return "FOUND"
        case .seeOther:
            return "SEE OTHER"
        case .notModified:
            return "NOT MODIFIED"
        case .useProxy:
            return "USE PROXY"
        case .temporaryRedirect:
            return "TEMPORARY REDIRECT"

        case .badRequest:
            return "BAD REQUEST"
        case .unauthorized:
            return "UNAUTHORIZED"
        case .paymentRequired:
            return "PAYMENT REQUIRED"
        case .forbidden:
            return "FORBIDDEN"
        case .notFound:
            return "NOT FOUND"
        case .methodNotAllowed:
            return "METHOD NOT ALLOWED"
        case .notAcceptable:
            return "NOT ACCEPTABLE"
        case .proxyAuthenticationRequired:
            return "PROXY AUTHENTICATION REQUIRED"
        case .requestTimeout:
            return "REQUEST TIMEOUT"
        case .conflict:
            return "CONFLICT"
        case .gone:
            return "GONE"
        case .lengthRequired:
            return "LENGTH REQUIRED"
        case .preconditionFailed:
            return "PRECONDITION FAILED"
        case .requestEntityTooLarge:
            return "REQUEST ENTITY TOO LARGE"
        case .requestURITooLong:
            return "REQUEST URI TOO LONG"
        case .unsupportedMediaType:
            return "UNSUPPORTED MEDIA TYPE"
        case .requestedRangeNotSatisfiable:
            return "REQUESTED RANGE NOT SATISFIABLE"
        case .expectationFailed:
            return "EXPECTATION FAILED"

        case .internalServerError:
            return "INTERNAL ERROR"
        case .notImplemented:
            return "NOT IMPLEMENTED"
        case .badGateway:
            return "BAD GATEWAY"
        case .serviceUnavailable:
            return "SERVICE UNAVAILABLE"
        case .gatewayTimeout:
            return "GATEWAY TIMEOUT"
        case .httpVersionNotSupported:
            return "HTTP VERSION NOT SUPPORTED"

        case .otherStatus(let status):
            return "Unrecognized failure status: \(status)"

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
