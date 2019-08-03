//
//  Method.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

/// [HTTP Method](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) for making requests
public enum Method {
    /// [GET](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET)
    ///
    /// The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
    case get

    /// [HEAD](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/HEAD)
    ///
    /// The HEAD method asks for a response identical to that of a GET request, but without the response body.
    case head

    /// [POST](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST)
    ///
    /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    case post

    /// [PUT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PUT)
    ///
    /// The PUT method replaces all current representations of the target resource with the request payload.
    case put

    /// [DELETE](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE)
    ///
    /// The DELETE method deletes the specified resource.
    case delete

    /// [CONNECT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/CONNECT)
    ///
    /// The CONNECT method establishes a tunnel to the server identified by the target resource.
    case connect

    /// [OPTIONS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/OPTIONS)
    ///
    /// The OPTIONS method is used to describe the communication options for the target resource.
    case options

    /// [TRACE](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/TRACE)
    ///
    /// The TRACE method performs a message loop-back test along the path to the target resource.
    case trace

    /// [PATCH](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PATCH)
    ///
    /// The PATCH method is used to apply partial modifications to a resource.
    case patch

    /// Catch all for all other methods
    case other(String)

    public init(rawValue: String) {
        switch rawValue.uppercased() {
        case "GET":
            self = .get
        case "HEAD":
            self = .head
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "DELETE":
            self = .delete
        case "CONNECT":
            self = .connect
        case "OPTIONS":
            self = .options
        case "TRACE":
            self = .trace
        case "PATCH":
            self = .patch
        default:
            self = .other(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .get:
            return "GET"
        case .head:
            return "HEAD"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .connect:
            return "CONNECT"
        case .options:
            return "OPTIONS"
        case .trace:
            return "TRACE"
        case .patch:
            return "PATCH"
        case .other(let other):
            return other
        }
    }
}

extension Method: Equatable {
    public static func ==(lhs: Method, rhs: Method) -> Bool {
        return lhs.rawValue.uppercased() == rhs.rawValue.uppercased()
    }
}
