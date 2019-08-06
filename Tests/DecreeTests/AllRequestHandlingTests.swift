//
//  AllRequestHandlingTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 8/6/19.
//

import XCTest

class AllRequestHandlingTests: XCTestCase {
    override func tearDown() {
        TestService.stopHandlingAllRequests()
    }

    func testHandlingRequests() {
        var handlerCalled = false
        TestService.startHandlingAllRequests(handler: { request in
            handlerCalled = true
            return (nil, nil, nil)
        })

        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })
        XCTAssertTrue(handlerCalled)

        // Should intercept all instances of TestService
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(to: TestService(errorConfiguring: false)), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })
    }
}
