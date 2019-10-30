//
//  MockSession.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Set expectations for [mocking a WebService](x-source-tag://WebServiceMocking)
/// - Tag: WebServiceMock
///
/// An expectation must be added for every request that is going to be made to the service.
/// If a request comes in that was not expected, it will throw an error.
public class WebServiceMock<S: WebService>: Session {
    var expectations = [AnyExpectation]()

    // -------------------------------------------------------------------------------------------
    // MARK: Emtpy Endpoints
    // -------------------------------------------------------------------------------------------

    /// Add expectation for an empty endpoint returning a specific result
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - result: The result to return when the expectation is met
    @discardableResult
    public func expect<E: EmptyEndpoint>(_ endpoint: E, andReturn result: EmptyResult) -> EmptyExpectation<E> where E.Service == S {
        return self.add(EmptyExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: result))
    }

    /// Add expectation for an empty endpoint type returning a specific result
    ///
    /// If you know exactly what path should be expected, use expect(_:andReturn:) instead.
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - result: The result to return when the expectation is met
    @discardableResult
    public func expectEndpoint<E: EmptyEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, andReturn result: EmptyResult) -> EmptyExpectation<E> where E.Service == S {
        return self.add(EmptyExpectation<E>(pathValidation: validatingPath, returning: result))
    }

    // -------------------------------------------------------------------------------------------
    // MARK: In Endpoints
    // -------------------------------------------------------------------------------------------

    /// Add expectation for an in endpoint with a specific input
    ///
    /// If the input matches exactly, the request will return success, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - input: The input to expect
    @discardableResult
    public func expect<E: InEndpoint>(_ endpoint: E, receiving input: E.Input) -> FixedInputInExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInExpectation<E>(pathValidation: endpoint.fixedPathValidation, expectedInput: input))
    }

    /// Add expectation for an in endpoint type with a specific input
    ///
    /// If the input matches exactly, the request will return success, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - input: The input to expect
    @discardableResult
    public func expectEndpoint<E: InEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, receiving input: E.Input) -> FixedInputInExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInExpectation<E>(pathValidation: validatingPath, expectedInput: input))
    }

    /// Add expectation for an in endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expect<E: InEndpoint>(_ endpoint: E, throwingError error: DecreeError) -> InExpectation<E> where E.Service == S {
        return self.add(InExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: .failure(error)))
    }

    /// Add expectation for an in endpoint type that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expectEndpoint<E: InEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, throwingError error: DecreeError) -> InExpectation<E> where E.Service == S {
        return self.add(InExpectation<E>(pathValidation: validatingPath, returning: .failure(error)))
    }

    /// Add expectation for an in endpoint with custom validation
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expect<E: InEndpoint>(_ endpoint: E, validatingInput validate: @escaping (E.Input) throws -> (EmptyResult)) -> CustomInExpectation<E> where E.Service == S {
        return self.add(CustomInExpectation<E>(pathValidation: endpoint.fixedPathValidation, validate: validate))
    }

    /// Add expectation for an in endpoint with custom validation
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expectEndpoint<E: InEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, validatingInput validate: @escaping (E.Input) throws -> (EmptyResult)) -> CustomInExpectation<E> where E.Service == S {
        return self.add(CustomInExpectation<E>(pathValidation: validatingPath, validate: validate))
    }

    // -------------------------------------------------------------------------------------------
    // MARK: Out Endpoints
    // -------------------------------------------------------------------------------------------

    /// Add expectation for an out endpoint returning a specific result
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expect<E: OutEndpoint>(_ endpoint: E, andReturn result: Result<E.Output, DecreeError>) -> OutExpectation<E> where E.Service == S {
        return self.add(OutExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: result))
    }

    /// Add expectation for an out endpoint type returning a specific result
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - result: The result to return when the expectation is met
    @discardableResult
    public func expectEndpoint<E: OutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, andReturn result: Result<E.Output, DecreeError>) -> OutExpectation<E> where E.Service == S {
        return self.add(OutExpectation<E>(pathValidation: validatingPath, returning: result))
    }

    /// Add expectation for a download from an out endpoint returning a specific result
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expectDownload<E: OutEndpoint>(_ endpoint: E, andReturn result: Result<URL, DecreeError>) -> OutDownloadExpectation<E> where E.Service == S {
        return self.add(OutDownloadExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: result))
    }

    /// Add expectation for a download from an out endpoint type returning a specific result
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - result: The result to return when the expectation is met
    @discardableResult
    public func expectEndpointDownload<E: OutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, andReturn result: Result<URL, DecreeError>) -> OutDownloadExpectation<E> where E.Service == S {
        return self.add(OutDownloadExpectation<E>(pathValidation: validatingPath, returning: result))
    }

    // -------------------------------------------------------------------------------------------
    // MARK: In/Out Endpoints
    // -------------------------------------------------------------------------------------------

    /// Add expectation for an in-out endpoint with a specific input and result
    ///
    /// If the input matches exactly, the request will return the result, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - input: The input to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expect<E: InOutEndpoint>(_ endpoint: E, receiving input: E.Input, andReturn result: Result<E.Output, DecreeError>) -> FixedInputInOutExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInOutExpectation<E>(pathValidation: endpoint.fixedPathValidation, expectedInput: input, returning: result))
    }

    /// Add expectation for an in-out endpoint with a specific input and result
    ///
    /// If the input matches exactly, the request will return the result, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - input: The input to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expectEndpoint<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, receiving input: E.Input, andReturn result: Result<E.Output, DecreeError>) -> FixedInputInOutExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInOutExpectation<E>(pathValidation: validatingPath, expectedInput: input, returning: result))
    }

    /// Add expectation for an in-out endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expect<E: InOutEndpoint>(_ endpoint: E, throwingError error: DecreeError) -> InOutExpectation<E> where E.Service == S {
        return self.add(InOutExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: .failure(error)))
    }

    /// Add expectation for an in-out endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expectEndpoint<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, throwingError error: DecreeError) -> InOutExpectation<E> where E.Service == S {
        return self.add(InOutExpectation<E>(pathValidation: validatingPath, returning: .failure(error)))
    }

    /// Add expectation for an in-out endpoint with custom validation
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expect<E: InOutEndpoint>(_ endpoint: E, validatingInput validate: @escaping (E.Input) throws -> (Result<E.Output, DecreeError>)) -> CustomInOutExpectation<E> where E.Service == S {
        return self.add(CustomInOutExpectation<E>(pathValidation: endpoint.fixedPathValidation, validate: validate))
    }

    /// Add expectation for an in-out endpoint with custom validation
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expectEndpoint<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, validatingInput validate: @escaping (E.Input) throws -> (Result<E.Output, DecreeError>)) -> CustomInOutExpectation<E> where E.Service == S {
        return self.add(CustomInOutExpectation<E>(pathValidation: validatingPath, validate: validate))
    }

    /// Add expectation for a download from an in-out endpoint with a specific input and result
    ///
    /// If the input matches exactly, the request will return the result, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - input: The input to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expectDownload<E: InOutEndpoint>(_ endpoint: E, receiving input: E.Input, andReturn result: Result<URL, DecreeError>) -> FixedInputInOutDownloadExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInOutDownloadExpectation<E>(pathValidation: endpoint.fixedPathValidation, expectedInput: input, returning: result))
    }

    /// Add expectation for a download from an in-out endpoint with a specific input and result
    ///
    /// If the input matches exactly, the request will return the result, otherwise it will throw an error.
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - input: The input to expect
    ///     - result: The result to return if the expectation is met
    @discardableResult
    public func expectEndpointDownload<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, receiving input: E.Input, andReturn result: Result<URL, DecreeError>) -> FixedInputInOutDownloadExpectation<E> where E.Input: Encodable, E.Service == S {
        return self.add(FixedInputInOutDownloadExpectation<E>(pathValidation: validatingPath, expectedInput: input, returning: result))
    }

    /// Add expectation for a download from an in-out endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expectDownload<E: InOutEndpoint>(_ endpoint: E, throwingError error: DecreeError) -> InOutDownloadExpectation<E> where E.Service == S {
        return self.add(InOutDownloadExpectation<E>(pathValidation: endpoint.fixedPathValidation, returning: .failure(error)))
    }

    /// Add expectation for a download from an in-out endpoint that will throw an error
    ///
    /// If the endpoint matches, the error will be thrown
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - error: Error to the throw if the expectation is met
    @discardableResult
    public func expectEndpointDownload<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, throwingError error: DecreeError) -> InOutDownloadExpectation<E> where E.Service == S {
        return self.add(InOutDownloadExpectation<E>(pathValidation: validatingPath, returning: .failure(error)))
    }

    /// Add expectation for a download from an in-out endpoint with custom validation
    ///
    /// - Parameters:
    ///     - endpoint: The endpoint to expect
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expectDownload<E: InOutEndpoint>(_ endpoint: E, validatingInput validate: @escaping (E.Input) throws -> (Result<URL, DecreeError>)) -> CustomInOutDownloadExpectation<E> where E.Service == S {
        return self.add(CustomInOutDownloadExpectation<E>(pathValidation: endpoint.fixedPathValidation, validate: validate))
    }

    /// Add expectation for a download from an in-out endpoint with custom validation
    ///
    /// - Parameters:
    ///     - type: The type of endpoint to expect
    ///     - validatingPath: Closure to validate the path of the endpoint is correct
    ///     - validate: A closure to validate the input and return a result to return for the request
    @discardableResult
    public func expectEndpointDownload<E: InOutEndpoint>(ofType type: E.Type, validatingPath: @escaping PathValidation, validatingInput validate: @escaping (E.Input) throws -> (Result<URL, DecreeError>)) -> CustomInOutDownloadExpectation<E> where E.Service == S {
        return self.add(CustomInOutDownloadExpectation<E>(pathValidation: validatingPath, validate: validate))
    }

    // -------------------------------------------------------------------------------------------
    // MARK: Custom
    // -------------------------------------------------------------------------------------------

    /// Add a custom expectation
    ///
    /// **For advanced uses only**
    @discardableResult
    public func add<E: AnyExpectation>(_ expectation: E) -> E {
        self.expectations.append(expectation)
        return expectation
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

    public func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        fatalError("Should not get called. It is special-cased.")
    }
}

extension Endpoint {
    var fixedPathValidation: PathValidation {
        return { actual in
            guard actual == self.path else {
                throw DecreeError(.incorrectExpectationPath(expected: self.path, actual: actual, endpoint: String(describing: type(of: self))), operationName: type(of: self).operationName)
            }
        }
    }
}
