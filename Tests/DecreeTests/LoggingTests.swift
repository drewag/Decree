//
//  LoggingTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/23/19.
//

import XCTest
@testable import Decree

class LoggingTests: MakeRequestTestCase {
    override func setUp() {
        super.setUp()

        Logger.shared.logs.removeAll()
        Logger.shared.logToMemory = true
    }

    override func tearDown() {
        Logger.shared.logToMemory = false
        Logger.shared.level = .none
    }

    func testNoLog() throws {
        Logger.shared.level = .none

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        try Empty().makeSynchronousRequest()

        XCTAssertEqual(Logger.shared.logs.count, 0)
    }

    func testEmptyInfoLogs() throws {
        Logger.shared.level = .info(filter: nil)

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        try Empty().makeSynchronousRequest()

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.Empty
                GET https://example.com/empty
                Accept: application/json
                Test: VALUE
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.Empty
                200 OK

                {"success": true}
                --------------------------------------------------------------
                """
            )
        }
    }

    func testInOutInfoLogs() throws {
        Logger.shared.level = .info(filter: nil)

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        let _ = try InOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.InOut
                POST https://example.com/inout
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.InOut
                200 OK

                {"success": true, "date": -14182980}
                --------------------------------------------------------------
                """
            )
        }
    }

    func testOutErrorLog() throws {
        Logger.shared.level = .info(filter: nil)

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: ResponseError.custom("Some Error"))
        let _ = try? InOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.InOut
                POST https://example.com/inout
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.InOut
                ERROR: Some Error
                200 OK

                {"success": true, "date": -14182980}
                --------------------------------------------------------------
                """
            )
        }
    }

    func testOutBadStatusLog() throws {
        Logger.shared.level = .info(filter: nil)

        self.session.fixedOutput = (data: validOutData, response: TestResponse(statusCode: 402), error: nil)
        let _ = try? InOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.InOut
                POST https://example.com/inout
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.InOut
                402 PAYMENT REQUIRED

                {"success": true, "date": -14182980}
                --------------------------------------------------------------
                """
            )
        }
    }

    func testNoResponseLogging() throws {
        Logger.shared.level = .info(filter: nil)

        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        let _ = try? InOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.InOut
                POST https://example.com/inout
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.InOut
                NO RESPONSE
                --------------------------------------------------------------
                """
            )
        }
    }

    func testLogServiceFiltering() {
        Logger.shared.level = .info(filter: "TestService")

        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        let _ = try? InOut().makeSynchronousRequest(with: .init(date: date))
        let _ = try? NoStandardInOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.InOut
                POST https://example.com/inout
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.InOut
                NO RESPONSE
                --------------------------------------------------------------
                """
            )
        }
    }

    func testLogEndpointFiltering() {
        Logger.shared.level = .info(filter: "TestService.In")

        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        let _ = try? InOut().makeSynchronousRequest(with: .init(date: date))
        let _ = try? In().makeSynchronousRequest(with: .init(date: date))
        let _ = try? Empty().makeSynchronousRequest()
        let _ = try? NoStandardInOut().makeSynchronousRequest(with: .init(date: date))

        XCTAssertEqual(Logger.shared.logs.count, 2)
        if Logger.shared.logs.count == 2 {
            XCTAssertEqual(Logger.shared.logs[0], """
                --------------------------------------------------------------
                Making Decree Request to TestService.In
                PUT https://example.com/in
                Accept: application/json
                Content-Type: application/json
                Test: VALUE

                {"date":-14182980,"string":"weird&=?<>characters","nullValue":null}
                --------------------------------------------------------------
                """
            )

            XCTAssertEqual(Logger.shared.logs[1], """
                --------------------------------------------------------------
                Received Decree Response from TestService.In
                NO RESPONSE
                --------------------------------------------------------------
                """
            )
        }
    }

}
