//
//  Endpoint.swift
//  Decree
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

    /// **OPTIONAL** The method to use when making a request to this endpoint
    ///
    /// Defaults to GET
    static var method: Method {get}

    /// The path to be appended to the Service's base URL
    var path: String {get}

    /// Set the requirements regarding authentication
    ///
    /// Defaults to optional
    static var authorizationRequirement: AuthorizationRequirement {get}

    /// **OPTIONAL** The format for parsing the output
    ///
    /// Defaults to JSON
    static var outputFormat: OutputFormat {get}

    /// **OPTIONAL** What this endpoint is doing e.g. "logging in"
    ///
    /// If defined, this will be used to improve error descriptions
    /// When in a title, it will be title cased
    /// When in descriptions, it will be lowercased
    static var operationName: String? {get}
}

/// Requirements for endpoints with input
///
/// Do not implment this protocol directly. Instead, implement
/// EmptyEndpoint, InEndpoint, OutEndpoint, or InOutEndpoint
public protocol EndpointWithInput: Endpoint {
    associatedtype Input: Encodable

    /// **OPTIONAL** The format for uploading the input
    ///
    /// Defaults to JSON
    static var inputFormat: InputFormat {get}
}

/// Requirements for endpoints with output
///
/// Do not implment this protocol directly. Instead, implement
/// EmptyEndpoint, InEndpoint, OutEndpoint, or InOutEndpoint
public protocol EndpointWithOutput: Endpoint {
    associatedtype Output: Decodable
}

/// Endpoint without input or output
public protocol EmptyEndpoint: Endpoint {}

/// Endpoint with only input
public protocol InEndpoint: EndpointWithInput {}

/// Endpoint with only output
public protocol OutEndpoint: EndpointWithOutput {}

/// Endpoint with both input and output
public protocol InOutEndpoint: EndpointWithInput, EndpointWithOutput {}

extension Endpoint {
    /// Default method to GET
    public static var method: Method { return .get }

    /// Default to including auth if present
    public static var authorizationRequirement: AuthorizationRequirement { return .optional }

    /// Default to JSON input
    public static var outputFormat: OutputFormat { return .JSON }

    /// Default to no operation name
    public static var operationName: String? { return nil }

    /// Defaults to undefined
    public static var successStatus: HTTPStatus? { return nil }

    /// Create a custom Decree error
    ///
    /// - Parameters:
    ///     - reason: Medium length description of the reason for the error
    ///     - details: Optional detailed description of the reason for the error
    ///     - isInternal: false if this error was caused by the end user. Defaults to true
    ///
    /// If isInternal is true, the message will include a request to report the bug if
    /// it continues to occur.
    public static func error(reason: String, details: String? = nil, isInternal: Bool = true) -> DecreeError {
        return DecreeError(.custom(reason, details: details, isInternal: isInternal), operationName: self.operationName)
    }
}

extension EndpointWithInput {
    /// Default to JSON input
    public static var inputFormat: InputFormat { return .JSON }
}
