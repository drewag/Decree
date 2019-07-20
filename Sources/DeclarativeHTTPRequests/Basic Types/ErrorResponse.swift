//
//  ErrorResponse.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

/// Format of an error returned from the service
public protocol AnyErrorResponse: Decodable {
    /// Message of the error to be returned
    var message: String {get}
}

/// Placeholder to indicate that there is no standard error format
public struct NoErrorResponse: AnyErrorResponse {
    public var message: String { return "Should not be returned" }
}
