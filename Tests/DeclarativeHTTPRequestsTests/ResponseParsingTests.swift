//
//  ResponseParsingTests.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import DeclarativeHTTPRequests

class ResponseParsingTests: MakeRequestTestCase {
    func testEmpty() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding BasicResponse")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "unsuccessful")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "parsed error")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try Empty().makeSynchronousRequest())
        XCTAssertThrowsError(try Out().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

    func testOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding BasicResponse")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "unsuccessful")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "parsed error")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try Out().makeSynchronousRequest().date.timeIntervalSince1970, -14182980)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

    func testIn() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding BasicResponse")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "unsuccessful")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "parsed error")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))

        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false)")})
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "other encoding error")})
        XCTAssertThrowsError(try In().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

    func testInOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding BasicResponse")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "unsuccessful")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "parsed error")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try InOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, -14182980)

        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false)")})
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "other encoding error")})
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

    func testIgnoringBasicAndErrorResponses() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, -14182980)

        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false)")})
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "other encoding error")})
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

    func testMinimalInOutRequest() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: failData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: successData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: invalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: errorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: validOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try MinimalInOut().makeSynchronousRequest(with: .init(date: date)).date.timeIntervalSince1970, 964124220.0)

        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false)")})
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "other encoding error")})
    }

    func testXMLOut() {
        self.session.fixedOutput = (data: nil, response: nil, error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No response returned")})

        self.session.fixedOutput = (data: nil, response: nil, error: RequestError.custom("custom"))
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "custom")})

        self.session.fixedOutput = (data: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "No data returned")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 201), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 201")})

        self.session.fixedOutput = (data: Data(), response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual("\($0)", "Error parsing response: The parser object encountered an internal error.")})

        self.session.fixedOutput = (data: xmlFailData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "unsuccessful")})

        self.session.fixedOutput = (data: xmlSuccessData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: xmlInvalidOutData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error decoding TestOutput")})

        self.session.fixedOutput = (data: xmlErrorMessageData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "parsed error")})

        self.session.fixedOutput = (data: xmlValidOutData, response: TestResponse(), error: nil)
        XCTAssertEqual(try XMLOut().makeSynchronousRequest().date.timeIntervalSince1970, -14182980)
        XCTAssertThrowsError(try XMLOut().makeSynchronousRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "error configuring")})
    }

}
