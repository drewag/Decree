//
//  MakeRequestTestCase.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import Decree

class MakeRequestTestCase: XCTestCase {
    let failData = #"{"success": false}"#.data(using: .utf8)!
    let errorMessageData = #"{"message": "parsed error"}"#.data(using: .utf8)!
    let successData = #"{"success": true}"#.data(using: .utf8)!
    let invalidOutData = #"{"success": true, "date": "1969-07-20"}"#.data(using: .utf8)!
    let validOutData = #"{"success": true, "date": -14182980}"#.data(using: .utf8)!

    let xmlFailData = "<root><success>false</success></root>".data(using: .utf8)!
    let xmlErrorMessageData = "<root><message>parsed error</message></root>".data(using: .utf8)!
    let xmlSuccessData = "<root><success>true</success></root>".data(using: .utf8)!
    let xmlInvalidOutData = "<root><success>true</success><date>asdf</date></root>".data(using: .utf8)!
    let xmlValidOutData = "<root><success>true</success><date>-14182980</date></root>".data(using: .utf8)!

    let date = Date(timeIntervalSince1970: -14182980)

    var session: TestURLSession {
        return TestService.shared.sessionOverride! as! TestURLSession
    }

    override func setUp() {
        TestService.shared.sessionOverride = TestURLSession.test
        self.session.fixedOutput = nil
        self.session.startedTasks.removeAll()
        self.session.fixedDownloadOutput = nil
        self.session.startedDownloadTasks.removeAll()
    }
}
