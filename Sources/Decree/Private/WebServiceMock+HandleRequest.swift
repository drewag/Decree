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
                    try type(of: self).validate(expected: expectation.recieving, actual: input, for: endpoint)
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
                    try type(of: self).validate(expected: expectation.recieving, actual: input, for: endpoint)
                    onComplete(expectation.result)
                case let expectation as ErrorExpectation:
                    onComplete(.failure(expectation.error))
                case let expecation as ValidatingInputAndOutputExpectation<E.Input, E.Output>:
                    onComplete(try expecation.validate(input))
                default:
                    fatalError("Should not be possible to create matching expectation that is not an expected type.")
                }
            }
            catch {
                onComplete(.failure(DecreeError(other: error, for: endpoint)))
            }
        }
    }

    /// Internal to allow for unit testing
    static func validate<Value: Encodable, E: Endpoint>(expected: Value, actual: Value, for endpoint: E) throws {
        // Special case strings
        if let expectedString = expected as? String {
            guard let actualString = actual as? String
                , expectedString == actualString
                else
            {
                throw DecreeError(.unexpectedInput(expected: expected, actual: actual, valuePath: "", endpoint: String(describing: E.self)), operationName: E.operationName)
            }
            return
        }

        // Special case data
        if let expectedData = expected as? Data {
            guard let actualData = actual as? Data
                , expectedData == actualData
                else
            {
                throw DecreeError(.unexpectedInput(expected: expected, actual: actual, valuePath: "", endpoint: String(describing: E.self)), operationName: E.operationName)
            }
            return
        }

        let encoder = JSONEncoder()
        let expectedData = try encoder.encode(expected)
        let actualData = try encoder.encode(actual)
        let expectedJSON = try JSONSerialization.jsonObject(with: expectedData, options: [])
        let actualJSON = try JSONSerialization.jsonObject(with: actualData, options: [])
        if let path = self.valuePathDifferentBetween(expectedJSON, and: actualJSON, path: "") {
            throw DecreeError(.unexpectedInput(expected: expected, actual: actual, valuePath: path, endpoint: String(describing: E.self)), operationName: E.operationName)
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

    static func valuePathDifferentBetween(_ lhs: Any, and rhs: Any, path: String) -> String? {
        if let lhs = lhs as? [String:Any] {
            guard let rhs = rhs as? [String:Any] else {
                return path
            }
            return self.valuePathDifferentBetween(lhs, and: rhs, path: path)
        }

        if let lhs = lhs as? [Any] {
            guard let rhs = rhs as? [Any] else {
                return path
            }
            return self.valuePathDifferentBetween(lhs, and: rhs, path: path)
        }

        if let lhs = lhs as? String {
            guard let rhs = rhs as? String
                , rhs == lhs
                else
            {
                return path
            }
            return nil
        }

        if let lhs = lhs as? NSNumber {
            guard let rhs = rhs as? NSNumber
                , rhs == lhs
                else
            {
                return path
            }
            return nil
        }

        if let _ = lhs as? NSNull {
            guard let _ = rhs as? NSNull else {
                return path
            }
            return nil
        }

        return path
    }

    static func valuePathDifferentBetween(_ lhs: [String:Any], and rhs: [String:Any], path: String) -> String? {
        guard lhs.count == rhs.count else {
            return path
        }

        let lKeys = lhs.keys.sorted()

        for key in lKeys {
            let newPath = path + (path.isEmpty ? "" : ".") + "\(key)"
            let left = lhs[key]!
            guard let right = rhs[key] else {
                return newPath
            }
            if let path = self.valuePathDifferentBetween(left, and: right, path: newPath) {
                return path
            }
        }

        return nil
    }

    static func valuePathDifferentBetween(_ lhs: [Any], and rhs: [Any], path: String) -> String? {
        guard lhs.count == rhs.count else {
            return path
        }

        for index in 0 ..< lhs.count {
            let newPath = path + (path.isEmpty ? "" : ".") + "\(index)"
            if let path = self.valuePathDifferentBetween(lhs[index], and: rhs[index], path: newPath) {
                return path
            }
        }

        return nil
    }
}
