//
//  GoogleAnalyticsTests.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import XCTest
import Decree

class GoogleAnalyticsTests: XCTestCase {
    let session = TestURLSession()

    override func setUp() {
        super.setUp()

        self.session.startedTasks.removeAll()
        Google.Analytics.shared.sessionOverride = self.session
        Google.Analytics.shared.trackingId = "UA-999999999-9"
    }

    func testCollectAllFields() throws {
        let input = Google.Analytics.Collect.Input(
            kind: .pageView(endpoint: "/test"),
            trackingId: "UA-222222222-2",
            ipAddress: "0.0.0.0",
            clientId: "CLIENT1",
            customField1: "Field1",
            customField2: "Field2",
            customField3: "Field3"
        )
        Google.Analytics.Collect().makeRequest(with: input) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://www.google-analytics.com/collect")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, "v=1&tid=UA-222222222-2&cid=CLIENT1&ds=api&t=pageview&dp=%2Ftest&uip=0.0.0.0&cd1=Field1&cd2=Field2&cd3=Field3")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "application/json")
    }

    func testCollectMinimalFields() throws {
        let input = Google.Analytics.Collect.Input(
            kind: .pageView(endpoint: "/test"),
            clientId: "CLIENT1"
        )
        Google.Analytics.Collect().makeRequest(with: input) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://www.google-analytics.com/collect")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, "v=1&tid=UA-999999999-9&cid=CLIENT1&ds=api&t=pageview&dp=%2Ftest")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "application/json")
    }
}
