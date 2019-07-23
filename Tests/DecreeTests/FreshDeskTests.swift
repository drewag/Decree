//
//  FreshDeskTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/22/19.
//

import XCTest
import Decree

class FreshDeskTests: XCTestCase {
    let session = TestURLSession()

    override func setUp() {
        super.setUp()

        self.session.startedTasks.removeAll()
        FreshDesk.shared.sessionOverride = self.session
        FreshDesk.shared.configure(domain: "domain", apiKey: "KEY")
    }

    func testCreateTicket() throws {
        let ticket = FreshDesk.Ticket(
            kind: .featureRequest,
            source: .mobihelp,
            status: .open,
            priority: .medium,
            name: "User Name",
            email: "user@example.com",
            subject: "Subject",
            description: "Description",
            attachments: [
                File(name: "file1.txt", text: "one"),
                File(name: "file2.txt", text: "two"),
            ]
        )
        FreshDesk.CreateTicket().makeRequest(with: ticket) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://domain.freshdesk.com/api/v2/tickets")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"type\"\r\n\r\nFeature Request\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"source\"\r\n\r\n5\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"status\"\r\n\r\n2\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"priority\"\r\n\r\n2\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nUser Name\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"email\"\r\n\r\nuser@example.com\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"subject\"\r\n\r\nSubject\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"description\"\r\n\r\nDescription\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"attachments[]\"; filename=\"file1.txt\"\r\nContent-Type: text/plain\r\n\r\none\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"attachments[]\"; filename=\"file2.txt\"\r\nContent-Type: text/plain\r\n\r\ntwo--__DECREE_BOUNDARY__--")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Content-Type"], "multipart/form-data; charset=utf-8; boundary=__DECREE_BOUNDARY__")
    }
}
