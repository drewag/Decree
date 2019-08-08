//
//  Expectations.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

/// An expectation for [mocking](x-source-tag://WebServiceMock)
///
/// You will only have to implement this protocol for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
public protocol AnyExpectation {
    static var typeName: String {get}

    var path: String {get}
}

// MARK: Core

/// An expectation for an EmptyEndpoint
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
open class EmptyExpectation<E: EmptyEndpoint>: AnyExpectation {
    public let path: String
    public var returning: EmptyResult

    public static var typeName: String {
        return "\(E.self)"
    }

    public init(path: String, returning: EmptyResult) {
        self.path = path
        self.returning = returning
    }

    open func validate(_ endpoint: E) throws {}
}

/// An expectation for an InEndpoint
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
open class InExpectation<E: InEndpoint>: AnyExpectation {
    public let path: String
    public var returning: EmptyResult

    public static var typeName: String {
        return "\(E.self)"
    }

    public init(path: String, returning: EmptyResult) {
        self.path = path
        self.returning = returning
    }

    open func validate(_ endpoint: E, input: E.Input) throws {}
}

/// An expectation for an out endpoint
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
open class OutExpectation<E: OutEndpoint>: AnyExpectation {
    public let path: String
    public var returning: Result<E.Output, DecreeError>

    public static var typeName: String {
        return "\(E.self)"
    }

    public init(path: String, returning: Result<E.Output, DecreeError>) {
        self.path = path
        self.returning = returning
    }

    open func validate(_ endpoint: E) throws {}
}

/// An expectation for an InOutEndpoint
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
open class InOutExpectation<E: InOutEndpoint>: AnyExpectation {
    public let path: String
    public var returning: Result<E.Output, DecreeError>

    public static var typeName: String {
        return "\(E.self)"
    }

    public init(path: String, returning: Result<E.Output, DecreeError>) {
        self.path = path
        self.returning = returning
    }

    open func validate(_ endpoint: E, input: E.Input) throws {}
}

// MARK: Specific Ins

/// An expectation for an InEndpoint endpoint with fixed input
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
public class FixedInputInExpectation<E: InEndpoint>: InExpectation<E> where E.Input: Encodable {
    public let expectedInput: E.Input

    public init(path: String, expectedInput: E.Input) {
        self.expectedInput = expectedInput

        super.init(path: path, returning: .success)
    }

    public override func validate(_ endpoint: E, input: E.Input) throws {
        try self.validate(expected: self.expectedInput, actual: input, for: endpoint)
    }
}

/// An expectation for an InEndpoint endpoint with a custom validator closure
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
public class CustomInExpectation<E: InEndpoint>: InExpectation<E>{
    public let validate: (E.Input) throws -> EmptyResult

    public init(path: String, validate: @escaping (E.Input) throws -> EmptyResult) {
        self.validate = validate

        super.init(path: path, returning: .success)
    }

    public override func validate(_ endpoint: E, input: E.Input) throws {
        self.returning = try self.validate(input)
    }
}

// MARK: Specific InOuts

/// An expectation for an InOutEndpoint endpoint with fixed input
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
public class FixedInputInOutExpectation<E: InOutEndpoint>: InOutExpectation<E> where E.Input: Encodable {
    public let expectedInput: E.Input

    public init(path: String, expectedInput: E.Input, returning: Result<E.Output, DecreeError>) {
        self.expectedInput = expectedInput

        super.init(path: path, returning: returning)
    }

    public override func validate(_ endpoint: E, input: E.Input) throws {
        try self.validate(expected: self.expectedInput, actual: input, for: endpoint)
    }
}

/// An expectation for an InOutEndpoint endpoint with a custom validator closure
///
/// You will only have to use this type for advanced
/// mock expectations. The vast majority of the time you will
/// use the built in expectations through [WebServiceMock](x-source-tag://WebServiceMock).
public class CustomInOutExpectation<E: InOutEndpoint>: InOutExpectation<E> {
    public let validate: (E.Input) throws -> Result<E.Output, DecreeError>

    public init(path: String, validate: @escaping (E.Input) throws -> Result<E.Output, DecreeError>) {
        self.validate = validate

        super.init(path: path, returning: .failure(DecreeError(.custom("Default expectation error.", details: nil, isInternal: false))))
    }

    public override func validate(_ endpoint: E, input: E.Input) throws {
        self.returning = try self.validate(input)
    }
}

// MARK: Validation

extension AnyExpectation {
    public func validate<E: Endpoint>(path: String, for: E) throws {
        guard path == self.path else {
            throw DecreeError(.incorrectExpectationPath(expected: self.path, actual: self.path, endpoint: String(describing: E.self)), operationName: E.operationName)
        }
    }

    public func validate<Value: Encodable, E: Endpoint>(expected: Value, actual: Value, for endpoint: E) throws {
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
