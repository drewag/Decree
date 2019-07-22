//
//  EmptyResultTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
import Decree

class EmptyResultTests: XCTestCase {
    func testGettingError() {
        XCTAssertNil(EmptyResult.success.error)
        XCTAssertEqual(EmptyResult.failure(RequestError.custom("custom")).error?.localizedDescription, "custom")
    }
}
