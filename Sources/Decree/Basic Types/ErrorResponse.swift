//
//  ErrorResponse.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

/// Format of an error returned from the service
///
/// Implement CustomStringConvertible to provide more details than `message`
public protocol AnyErrorResponse: Decodable {
    /// Message of the error to be returned
    var message: String {get}

    /// False if this error was caused by the end user
    ///
    /// If true, the message will include a request to report the bug if
    /// it continues to occure.
    ///
    /// Defaults to true
    var isInternal: Bool {get}
}

/// Placeholder to indicate that there is no standard error format
public struct NoErrorResponse: AnyErrorResponse {
    public var message: String { return "Should not be returned" }
}

extension AnyErrorResponse {
    public var isInternal: Bool { return true }
}
