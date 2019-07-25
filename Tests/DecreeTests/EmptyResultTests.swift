//
//  EmptyResultTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
@testable import Decree

class EmptyResultTests: XCTestCase {
    func testGettingError() {
        XCTAssertNil(EmptyResult.success.error)
        let error = DecreeError(.custom("custom", details: "details", isInternal: false), operationName: nil)
        XCTAssertEqual(EmptyResult.failure(error).error?.localizedDescription, "Error making request: custom")
    }
}
