//
//  MockingSession+ResponseHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

extension WebServiceMock {
    func handle<E: EmptyEndpoint>(for endpoint: E, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        callbackQueue.async {
            do {
                switch try self.nextExpectationMatching(endpoint) {
                case let expectation as EmptyExpectation:
                    onComplete(expectation.returning)
                default:
                    fatalError("Should not be possible to create matching expectation that is not an expected type.")
                }
            }
            catch {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }

    func handle<E: InEndpoint>(for endpoint: E, input: E.Input, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: EmptyResult) -> ()) where E.Input: Encodable {
        callbackQueue.async {
            do {
                switch try self.nextExpectationMatching(endpoint) {
                case let expectation as FixedInputExpectation<E.Input>:
                    try self.validate(expected: expectation.recieving, actual: input, for: endpoint)
                    onComplete(.success)
                case let expectation as ErrorExpectation:
                    onComplete(.failure(expectation.error))
                case let expectation as ValidatingInputExpectation<E.Input>:
                    onComplete(try expectation.validate(input))
                default:
                    fatalError("Should not be possible to create matching expectation that is not an expected type.")
                }
            }
            catch {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }

    func handle<E: OutEndpoint>(for endpoint: E, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<E.Output, DecreeError>) -> ()) {
        callbackQueue.async {
            do {
                switch try self.nextExpectationMatching(endpoint) {
                case let expectation as OutputExpecation<E.Output>:
                    onComplete(expectation.result)
                default:
                    fatalError("Should not be possible to create matching expectation that is not an expected type.")
                }
            }
            catch {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }

    func handle<E: InOutEndpoint>(for endpoint: E, input: E.Input, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<E.Output, DecreeError>) -> ()) where E.Input: Encodable {
        callbackQueue.async {
            do {
                switch try self.nextExpectationMatching(endpoint) {
                case let expectation as FixedInputAndOutputExpectation<E.Input, E.Output>:
                    try self.validate(expected: expectation.recieving, actual: input, for: endpoint)
                    onComplete(expectation.result)
                case let expectation as ErrorExpectation:
                    onComplete(.failure(expectation.error))
                case let expecation as ValidatingInputAndOutputExpectation<E.Input, E.Output>:
                    onComplete(try expecation.validate(input))
                default:
                    fatalError("Should not be possible to create matching expectation that is not an expected type.")
                }        }
            catch {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }
}

private extension WebServiceMock {
    func nextExpectationMatching<E: Endpoint>(_ endpoint: E) throws -> AnyExpectation {
        guard !self.expectations.isEmpty else {
            throw DecreeError(.unexpectedEndpoint(String(describing: E.self)), operationName: E.operationName)
        }

        let expecation = self.expectations.removeFirst()

        guard expecation.type is E.Type else {
            throw DecreeError(.incorrectExpecation(expected: String(describing: expecation.type), actual: String(describing: E.self)), operationName: E.operationName)
        }

        guard expecation.path == endpoint.path else {
            throw DecreeError(.incorrectExpectationPath(expected: expecation.path, actual: endpoint.path, endpoint: String(describing: E.self)), operationName: E.operationName)
        }

        return expecation
    }

    func validate<Value: Encodable, E: Endpoint>(expected: Value, actual: Value, for endpoint: E) throws {
        let encoder = JSONEncoder()
        let expectedData = try encoder.encode(expected)
        let actualData = try encoder.encode(actual)
        guard expectedData == actualData else {
            throw DecreeError(.unexpectedInput(expected: expected, actual: actual, endpoint: String(describing: E.self)), operationName: E.operationName)
        }
    }
}
