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
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
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
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, #"{"date":-14182980,"string":"weird&=?characters"}"#)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, #"{"date":-14182980,"string":"weird&=?characters"}"#)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
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
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
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
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["TEST"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout?date=-14182980.0&string=weird%26%3D?characters")
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

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 500")})

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

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 500")})

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

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 500")})

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

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 500")})

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

        self.session.fixedOutput = (data: Data(), response: TestResponse(statusCode: 500), error: nil)
        XCTAssertThrowsError(try NoStandardInOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Bad status code: 500")})

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

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}
