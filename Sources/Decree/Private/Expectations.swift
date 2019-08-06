//
//  Expectations.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

protocol AnyExpectation {
    var type: Any {get}
    var path: String {get}
}

// MARK: Empty

struct EmptyExpectation: AnyExpectation {
    let type: Any
    let path: String
    let returning: EmptyResult
}

// MARK: In

struct FixedInputExpectation<Input: Encodable>: AnyExpectation {
    let type: Any
    let path: String
    let recieving: Input
}

struct ErrorExpectation: AnyExpectation {
    let type: Any
    let path: String
    let error: DecreeError
}

struct ValidatingInputExpectation<Input>: AnyExpectation {
    let type: Any
    let path: String
    let validate: (Input) throws -> (EmptyResult)
}

// MARK: Out

struct OutputExpecation<Output>: AnyExpectation {
    let type: Any
    let path: String
    let result: Result<Output, DecreeError>
}

// MARK: InOut

struct FixedInputAndOutputExpectation<Input: Encodable, Output>: AnyExpectation {
    let type: Any
    let path: String
    let recieving: Input
    let result: Result<Output, DecreeError>
}

struct ValidatingInputAndOutputExpectation<Input, Output>: AnyExpectation {
    let type: Any
    let path: String
    let validate: (Input) throws -> (Result<Output, DecreeError>)
}
