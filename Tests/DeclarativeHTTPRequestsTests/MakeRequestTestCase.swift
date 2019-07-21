//
//  MakeRequestTestCase.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import DeclarativeHTTPRequests

class MakeRequestTestCase: XCTestCase {
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
}
