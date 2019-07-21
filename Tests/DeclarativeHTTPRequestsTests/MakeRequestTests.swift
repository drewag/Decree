//
//  MakeRequestTests.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
import DeclarativeHTTPRequests

class MakeRequestTests: XCTestCase {
    let failData = #"{"success": false}"#.data(using: .utf8)!
    let errorMessageData = #"{"message": "parsed error"}"#.data(using: .utf8)!
    let successData = #"{"success": true}"#.data(using: .utf8)!
    let invalidOutData = #"{"success": true, "date": "1969-07-20"}"#.data(using: .utf8)!
    let validOutData = #"{"success": true, "date": -14182980}"#.data(using: .utf8)!
    let date = Date(timeIntervalSince1970: -14182980)

    var session: TestURLSession {
        return TestService.shared.sessionOverride! as! TestURLSession
    }

    override func setUp() {
        self.session.fixedOutput = nil
        self.session.startedTasks.removeAll()
    }

    func testEmptyRequestFlow() {
        var result: EmptyResult?
        Empty().makeRequest() { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/empty")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNil(result?.error)
    }

    func testOutRequestFlow() {
        var result: Result<Out.Output, Error>?
        Out().makeRequest() { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/out")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    func testInRequestFlow() {
        var result: EmptyResult?
        In().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "PUT")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["date"]?.interval, -14182980)
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["string"]?.string, "weird&=?characters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNil(result?.error)
    }

    func testInOutRequestFlow() {
        var result: Result<InOut.Output, Error>?
        InOut().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["date"]?.interval, -14182980)
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["string"]?.string, "weird&=?characters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    func testURLQueryInRequestFlow() {
        var result: EmptyResult?
        URLQueryIn().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "PUT")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in?date=-14182980.0&string=weird%26%3D?characters")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNil(result?.error)
    }

    func testURLQueryInOutRequestFlow() {
        var result: Result<InOut.Output, Error>?
        URLQueryInOut().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout?date=-14182980.0&string=weird%26%3D?characters")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    func testFormInRequestFlow() {
        var result: EmptyResult?
        FormIn().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "PUT")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3Fcharacters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNil(result?.error)
    }

    func testFormInOutRequestFlow() {
        var result: Result<InOut.Output, Error>?
        FormInOut().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3Fcharacters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }


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

        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?characters\", otherError: false)")})
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

        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?characters\", otherError: false)")})
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

        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?characters\", otherError: false)")})
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

        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error encoding TestInput(date: nil, string: \"weird&=?characters\", otherError: false)")})
        XCTAssertThrowsError(try MinimalInOut().makeSynchronousRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "other encoding error")})
    }

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

extension Result {
    var error: Failure? {
        switch self {
        case .failure(let failure):
            return failure
        case .success:
            return nil
        }
    }

    var output: Success? {
        switch self {
        case .failure:
            return nil
        case .success(let success):
            return success
        }
    }
}

enum Raw: Decodable {
    case string(String)
    case interval(TimeInterval)

    var string: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var interval: TimeInterval? {
        switch self {
        case .interval(let interval):
            return interval
        default:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self = .interval(try container.decode(TimeInterval.self))
        }
        catch {
            self = .string(try container.decode(String.self))
        }
    }
}

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }

    var jsonDict: [String:Raw] {
        let decoder = JSONDecoder()
        return (try? decoder.decode([String:Raw].self, from: self)) ?? [:]
    }
}

struct ExampleService: WebService {
    // There is no service wide standard response format
    typealias BasicResponse = NoBasicResponse
    typealias ErrorResponse = NoErrorResponse

    // Requests should use this service instance by default
    static var shared = ExampleService()

    // All requests will be sent to their endpoint at "https://example.com"
    let baseURL = URL(string: "https://example.com")!
}
