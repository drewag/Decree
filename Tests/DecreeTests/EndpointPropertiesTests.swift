//
//  File.swift
//  
//
//  Created by Andrew Wagner on 10/15/19.
//

import XCTest
import Decree

class EndpointPropertiesTests: MakeRequestTestCase {
    func testOverridingBaseURL() {
        var result: EmptyResult?
        EmptyOverride().makeRequest(callbackQueue: nil) { r in
            result = r
        }
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedTasks.count, 1)
        XCTAssertEqual(self.session.startedTasks[0].request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedTasks[0].request.url?.absoluteString, "http://other.com/with/path/empty")
        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
    }
}

struct EmptyOverride: EmptyEndpoint {
    typealias Service = TestService
    static let operationName: String? = "Emptying"

    let path = "empty"

    var baseURLOverride: URL? = URL(string: "http://other.com/with/path")
}
