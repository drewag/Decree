//
//  MakeRequestTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
import Decree

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
        XCTAssertNotNil(result)
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["string"]?.string, "weird&=?<>characters")
        XCTAssertTrue(self.session.startedTasks[0].request.httpBody?.jsonDict["nullValue"]?.isNil ?? false)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNotNil(result)
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.jsonDict["string"]?.string, "weird&=?<>characters")
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
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in?date=-14182980.0&string=weird%26%3D?%3C%3Echaracters&nullValue")
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
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout?date=-14182980.0&string=weird%26%3D?%3C%3Echaracters&nullValue")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3F%3C%3Echaracters&nullValue=")
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
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.string, "date=-14182980.0&string=weird%26%3D%3F%3C%3Echaracters&nullValue=")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    func testXMLInRequestFlow() {
        var result: EmptyResult?
        XMLIn().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "PUT")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.xmlDict["date"]??.interval, -14182980)
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.xmlDict["string"]??.string, "weird&=?<>characters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "text/xml")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/in")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNil(result?.error)
    }

    func testXMLInOutRequestFlow() {
        var result: Result<InOut.Output, Error>?
        XMLInOut().makeRequest(with: .init(date: date)) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.xmlDict["date"]??.interval, -14182980)
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody?.xmlDict["string"]??.string, "weird&=?<>characters")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], "text/xml")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    func testRedirectFlow() {
        var result: EmptyResult?
        Empty().makeRequest() { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "https://example.com/empty")
        self.session.startedTasks[0].complete(Data(), TestResponse(statusCode: 299), nil)

        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 2)
        XCTAssertEqual(self.session.startedTasks[1].request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedTasks[1].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[1].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[1].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[1].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[1].request.url?.absoluteString, "https://example.com/redirected")
        self.session.startedTasks[1].complete(successData, TestResponse(), nil)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
    }
}
