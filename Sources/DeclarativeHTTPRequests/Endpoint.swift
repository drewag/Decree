//
//  Endpoint.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

/// Core requirements for all endpoints
///
/// Do not implment this protocol directly. Instead, implement
/// EmptyEndpoint, InEndpoint, OutEndpoint, or InOutEndpoint
public protocol Endpoint {
    /// The service that provides this endpoint
    associatedtype Service: WebService

    /// The method to use when making a request to this endpoint
    static var method: Method {get}

    /// The path to be appended to the Service's base URL
    var path: String {get}
}

/// Endpoint without input or output
public protocol EmptyEndpoint: Endpoint {}

/// Endpoint with only input
public protocol InEndpoint: Endpoint {
    associatedtype Input: Encodable
}

/// Endpoint with only output
public protocol OutEndpoint: Endpoint {
    associatedtype Output: Decodable
}

/// Endpoint with both input and output
public protocol InOutEndpoint: Endpoint {
    associatedtype Input: Encodable
    associatedtype Output: Decodable
}
