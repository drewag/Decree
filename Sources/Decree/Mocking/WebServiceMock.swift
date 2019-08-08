//
//  MockSession.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

/// Set expectations for [mocking a WebService](x-source-tag://WebServiceMocking)
/// - Tag: WebServiceMock
///
/// An expectation must be added for every request that is going to be made to the service.
/// If a request comes in that was not expected, it will throw an error.
public class WebServiceMock<S: WebService>: Session {
    var expectations = [AnyExpectation]()

    // MARK: Emtpy Endpoints

    /// Add expectation for an empty endpoint returning a specific result
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - result: The result to return when the expectation is met
    public func expect<E: EmptyEndpoint>(_ endpoint: E, andReturn result: EmptyResult) where E.Service == S {
        self.add(EmptyExpectation<E>(path: endpoint.path, returning: result))
    }

    // MARK: In Endpoints

    /// Add expectation for an in endpoint with a specific input
    ///
    /// If the input matches exactly, the request will return success, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - input: The input to expect
    public func expect<E: InEndpoint>(_ endpoint: E, recieving input: E.Input) where E.Input: Encodable, E.Service == S {
        self.add(FixedInputInExpectation<E>(path: endpoint.path, expectedInput: input))
    }

    /// Add expectation for an in endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - error: Error to the throw if the expectation is met
    public func expect<E: InEndpoint>(_ endpoint: E, throwingError error: DecreeError) {
        self.add(InExpectation<E>(path: endpoint.path, returning: .failure(error)))
    }

    /// Add expectation for an in endpoint with custom validation
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - validate: A closure to validate the input and return a result to return for the request
    public func expect<E: InEndpoint>(_ endpoint: E, validatingInput validate: @escaping (E.Input) throws -> (EmptyResult)) where E.Service == S {
        self.add(CustomInExpectation<E>(path: endpoint.path, validate: validate))
    }

    // MARK: Out Endpoints

    /// Add expectation for an out endpoint returning a specific result
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - result: The result to return if the expectation is met
    public func expect<E: OutEndpoint>(_ endpoint: E, andReturn result: Result<E.Output, DecreeError>) where E.Service == S {
        self.add(OutExpectation<E>(path: endpoint.path, returning: result))
    }

    // MARK: In/Out Endpoints

    /// Add expectation for an in-out endpoint with a specific input and result
    ///
    /// If the input matches exactly, the request will return the result, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - input: The input to expect
    ///     - result: The result to return if the expectation is met
    public func expect<E: InOutEndpoint>(_ endpoint: E, recieving input: E.Input, andReturn result: Result<E.Output, DecreeError>) where E.Input: Encodable, E.Service == S {
        self.add(FixedInputInOutExpectation<E>(path: endpoint.path, expectedInput: input, returning: result))
    }

    /// Add expectation for an in-out endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - error: Error to the throw if the expectation is met
    public func expect<E: InOutEndpoint>(_ endpoint: E, throwingError error: DecreeError) where E.Service == S {
        self.add(InOutExpectation<E>(path: endpoint.path, returning: .failure(error)))
    }

    /// Add expectation for an in-out endpoint with custom validation
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - validate: A closure to validate the input and return a result to return for the request
    public func expect<E: InOutEndpoint>(_ endpoint: E, validatingInput validate: @escaping (E.Input) throws -> (Result<E.Output, DecreeError>)) where E.Service == S {
        self.add(CustomInOutExpectation<E>(path: endpoint.path, validate: validate))
    }

    // MARK: Custom

    /// Add a custom expectation
    ///
    /// **For advanced uses only**
    public func add(_ expectation: AnyExpectation) {
        self.expectations.append(expectation)
    }

    /// Get the next expectation
    ///
    /// **For advanced uses only**
    ///
    /// - Parameter endpoint: the endpoint to use for error reporting
    public func nextExpectation<E: Endpoint>(for endpoint: E) throws -> AnyExpectation {
        guard !self.expectations.isEmpty else {
            throw DecreeError(.unexpectedEndpoint(String(describing: E.self)), operationName: E.operationName)
        }
        return self.expectations.removeFirst()
    }

    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError("Should not get called. It is special-cased.")
    }
}
