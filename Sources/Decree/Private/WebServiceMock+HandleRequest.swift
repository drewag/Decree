//
//  MockingSession+ResponseHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

extension WebServiceMock {
    func handle<E: EmptyEndpoint>(for endpoint: E, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: EmptyResult) -> ()) {
        do {
            let next = try self.nextExpectation(for: endpoint)
            switch next {
            case let expectation as EmptyExpectation<E>:
                try expectation.validate(path: endpoint.path, for: endpoint)
                try expectation.validate(endpoint)
                DispatchQueue(label: "background").async {
                    callbackQueue.async {
                        onComplete(expectation.returning)
                        expectation.fulfill()
                    }
                }
            default:
                throw DecreeError(.incorrectExpecation(expected: type(of: next).typeName, actual: "\(E.self)"), operationName: E.operationName)
            }
        }
        catch {
            onComplete(.failure(DecreeError(other: error, for: endpoint)))
        }
    }

    func handle<E: InEndpoint>(for endpoint: E, input: E.Input, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: EmptyResult) -> ()) where E.Input: Encodable {
        do {
            let next = try self.nextExpectation(for: endpoint)
            switch next {
            case let expectation as InExpectation<E>:
                try expectation.validate(path: endpoint.path, for: endpoint)
                try expectation.validate(endpoint, input: input)
                DispatchQueue(label: "background").async {
                    callbackQueue.async {
                        onComplete(expectation.returning)
                        expectation.fulfill()
                    }
                }
            default:
                throw DecreeError(.incorrectExpecation(expected: type(of: next).typeName, actual: "\(E.self)"), operationName: E.operationName)
            }
        }
        catch {
            onComplete(.failure(DecreeError(other: error, for: endpoint)))
        }
    }

    func handle<E: OutEndpoint>(for endpoint: E, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<E.Output, DecreeError>) -> ()) {
        do {
            let next = try self.nextExpectation(for: endpoint)
            switch next {
            case let expectation as OutExpectation<E>:
                try expectation.validate(path: endpoint.path, for: endpoint)
                try expectation.validate(endpoint)
                DispatchQueue(label: "background").async {
                    callbackQueue.async {
                        onComplete(expectation.returning)
                        expectation.fulfill()
                    }
                }
            default:
                throw DecreeError(.incorrectExpecation(expected: type(of: next).typeName, actual: "\(E.self)"), operationName: E.operationName)
            }
        }
        catch {
            onComplete(.failure(DecreeError(other: error, for: endpoint)))
        }
    }

    func handle<E: InOutEndpoint>(for endpoint: E, input: E.Input, callbackQueue: DispatchQueue?, onComplete: @escaping (_ result: Result<E.Output, DecreeError>) -> ()) where E.Input: Encodable {
        do {
            let next = try self.nextExpectation(for: endpoint)
            switch next {
            case let expectation as InOutExpectation<E>:
                try expectation.validate(path: endpoint.path, for: endpoint)
                try expectation.validate(endpoint, input: input)
                DispatchQueue(label: "background").async {
                    callbackQueue.async {
                        onComplete(expectation.returning)
                        expectation.fulfill()
                    }
                }
            default:
                throw DecreeError(.incorrectExpecation(expected: type(of: next).typeName, actual: "\(E.self)"), operationName: E.operationName)
            }
        }
        catch {
            onComplete(.failure(DecreeError(other: error, for: endpoint)))
        }
    }
}
