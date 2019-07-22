//
//  StatusCodeValidationTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import Decree

class StatusCodeValidationTests: MakeRequestTestCase {
    func testStatusCodeValidation() {
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 300), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "MULTIPLE CHOICES")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 301), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "MOVED PERMANENTLY")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 302), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "FOUND")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 303), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "SEE OTHER")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 304), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "NOT MODIFIED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 305), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "USE PROXY")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 307), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "TEMPORARY REDIRECT")})

        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 400), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "BAD REQUEST")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 401), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "UNAUTHORIZED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 402), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "PAYMENT REQUIRED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 403), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "FORBIDDEN")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 404), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "NOT FOUND")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 405), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "METHOD NOT ALLOWED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 406), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "NOT ACCEPTABLE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 407), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "PROXY AUTHENTICATION REQUIRED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 408), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "REQUEST TIMEOUT")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 409), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "CONFLICT")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 410), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "GONE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 411), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "LENGTH REQUIRED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 412), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "PRECONDITION FAILED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 413), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "REQUEST ENTITY TOO LARGE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 414), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "REQUEST URI TOO LONG")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 415), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "UNSUPPORTED MEDIA TYPE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 416), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "REQUESTED RANGE NOT SATISFIABLE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 417), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "EXPECTATION FAILED")})


        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "INTERNAL ERROR")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 501), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "NOT IMPLEMENTED")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 502), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "BAD GATEWAY")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 503), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "SERVICE UNAVAILABLE")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 504), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "GATEWAY TIMEOUT")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 505), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "HTTP VERSION NOT SUPPORTED")})

        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 600), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Unrecognized failure status: 600")})
    }
}
