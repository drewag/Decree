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
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 300 MULTIPLE CHOICES\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 301), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 301 MOVED PERMANENTLY\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 302), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 302 FOUND\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 303), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 303 SEE OTHER\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 304), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 304 NOT MODIFIED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 305), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 305 USE PROXY\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 307), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 307 TEMPORARY REDIRECT\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 400), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 400 BAD REQUEST\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 401), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: You are not authorized.")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 402), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 402 PAYMENT REQUIRED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 403), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: You are not authorized.")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 404), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 404 NOT FOUND\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 405), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 405 METHOD NOT ALLOWED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 406), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 406 NOT ACCEPTABLE\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 407), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 407 PROXY AUTHENTICATION REQUIRED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 408), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 408 REQUEST TIMEOUT\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 409), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 409 CONFLICT\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 410), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: This app is out of date. Please update to the latest version.")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 411), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 411 LENGTH REQUIRED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 412), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 412 PRECONDITION FAILED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 413), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 413 REQUEST ENTITY TOO LARGE\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 414), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 414 REQUEST URI TOO LONG\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 415), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 415 UNSUPPORTED MEDIA TYPE\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 416), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 416 REQUESTED RANGE NOT SATISFIABLE\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 417), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 417 EXPECTATION FAILED\"")})


        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 500 INTERNAL ERROR\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 501), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 501 NOT IMPLEMENTED\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 502), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: The web server appears to be down.")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 503), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 503 SERVICE UNAVAILABLE\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 504), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 504 GATEWAY TIMEOUT\"")})
        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 505), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"HTTP error: 505 HTTP VERSION NOT SUPPORTED\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(statusCode: 600), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"Unrecognized HTTP error: 600\"")})
    }
}
