//
//  MakeRequestTests.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
import DeclarativeHTTPRequests

class RequestFlowTests: MakeRequestTestCase {
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
        XCTAssertTrue(self.session.startedTasks[0].request.httpBody?.jsonDict["nullValue"]?.isNil ?? false)
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
        XCTAssertTrue(self.session.startedTasks[0].request.httpBody?.jsonDict["nullValue"]?.isNil ?? false)
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
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in?date=-14182980.0&string=weird%26%3D?characters&nullValue")
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
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout?date=-14182980.0&string=weird%26%3D?characters&nullValue")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3Fcharacters&nullValue=")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3Fcharacters&nullValue=")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }
}
