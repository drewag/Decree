//
//  AuthenticationTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import XCTest
import Decree

class AuthenticationTests: MakeRequestTestCase {
    func testNoAuthentication() {
        AuthenticatedService.shared.authorization = .basic(username: "user", password: "secret")

        NoAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], nil)
    }

    func testOptionalAuthentication() {
        AuthenticatedService.shared.authorization = .none

        OptionalAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], nil)

        AuthenticatedService.shared.authorization = .basic(username: "user", password: "secret")
        OptionalAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "Basic dXNlcjpzZWNyZXQ=")

        AuthenticatedService.shared.authorization = .bearer(base64Token: "TOKEN")
        OptionalAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "Bearer TOKEN")

        AuthenticatedService.shared.authorization = .custom(key: "Key", value: "value")
        OptionalAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Key"], "value")
    }

    func testRequiredAuthencitation() {
        AuthenticatedService.shared.authorization = .basic(username: "user", password: "secret")
        RequiredAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "Basic dXNlcjpzZWNyZXQ=")

        AuthenticatedService.shared.authorization = .bearer(base64Token: "TOKEN")
        RequiredAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Authorization"], "Bearer TOKEN")

        AuthenticatedService.shared.authorization = .custom(key: "Key", value: "value")
        RequiredAuthEmpty().makeRequest() { _ in }
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Key"], "value")

        AuthenticatedService.shared.authorization = .none
        XCTAssertThrowsError(try RequiredAuthEmpty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.")})
    }
}
