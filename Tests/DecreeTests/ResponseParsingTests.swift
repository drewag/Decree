//
//  ResponseParsingTests.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import Decree

class ResponseParsingTests: MakeRequestTestCase {
    func testEmpty() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: Empty.error(reason:"custom"))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try Empty().makeSynchronousRequest())
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: Out.error(reason:"custom"))
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try Out().makeSynchronousRequest().date.timeIntervalSince1970, -14182980)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testIn() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: In.error(reason:"custom"))
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))

        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).\"")})
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { print($0); XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"other encoding error\"")})
        XCTAssertThrowsError(try In().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testInOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: InOut.error(reason:"custom"))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try InOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, -14182980)

        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).\"")})
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other encoding error\"")})
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testIgnoringBasicAndErrorResponses() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: NoStandardInOut.error(reason:"custom"))
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, -14182980)

        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).\"")})
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"other encoding error\"")})
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testMinimalInOutRequest() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: MinimalInOut.error(reason:"custom"))
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, 964124220.0)

        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).\"")})
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"other encoding error\"")})
    }

    func testXMLOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: XMLOut.error(reason:"custom"))
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual("\($0)", "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: xmlFailData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: xmlSuccessData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: xmlInvalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"Failed to decode TestOutput.\"")})

        self.session.fixedOutput = (data: xmlErrorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: xmlValidOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try XMLOut().makeSynchronousRequest().date.timeIntervalSince1970, -14182980)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error xmlouting: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testTextOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: Out.error(reason:"custom"))
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try TextOut().makeSynchronousRequest(), "{\"success\": true, \"date\": -14182980}")
        XCTAssertThrowsError(try TextOut().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testTextIn() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: TextIn.error(reason:"custom"))
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try TextIn().makeSynchronousRequest(with: "text"))

        XCTAssertThrowsError(try TextIn().makeSynchronousRequest(to: .sharedErrorConfiguring, with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testTextInOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: TextInOut.error(reason:"custom"))
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try TextInOut().makeSynchronousRequest(with: "text"), "{\"success\": true, \"date\": -14182980}")

        XCTAssertThrowsError(try TextInOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: "text"), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testDataOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: DataOut.error(reason:"custom"))
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try DataOut().makeSynchronousRequest().string, "{\"success\": true, \"date\": -14182980}")
        XCTAssertThrowsError(try DataOut().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testDataIn() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: DataIn.error(reason:"custom"))
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try DataIn().makeSynchronousRequest(with: "text".data(using: .utf8)!))

        XCTAssertThrowsError(try DataIn().makeSynchronousRequest(to: .sharedErrorConfiguring, with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinning: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testDataInOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedOutput = (data: nil, response: nil, error: DataInOut.error(reason:"custom"))
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"Bad status code: 201\"")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"No data returned.\"")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"unsuccessful\"")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"parsed error\"")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try DataInOut().makeSynchronousRequest(with: "text".data(using: .utf8)!).string, "{\"success\": true, \"date\": -14182980}")

        XCTAssertThrowsError(try DataInOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: "text".data(using: .utf8)!), "", { XCTAssertEqual($0.localizedDescription, "Error textinouting: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }
}
