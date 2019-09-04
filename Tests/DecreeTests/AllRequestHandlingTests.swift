//
//  AllRequestHandlingTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 8/6/19.
//

import XCTest
import Decree

class AllRequestHandlingTests: XCTestCase {
    override func tearDown() {
        TestService.stopHandlingAllRequests()
    }

    func testDeprecatedHandlingRequests() {
        var handlerCalled = false
        TestService.startHandlingAllRequests(handler: { request in
            handlerCalled = true
            return (nil, nil, nil)
        })

        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })
        XCTAssertTrue(handlerCalled)

        // Should intercept all instances of TestService
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(to: TestService(errorConfiguring: false)), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })

        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error making request: An internal error has occured. If it continues, please contact support with the description \"Using deprecated all requests handler that does not support download requests\"") })
    }

    func testHandlingRequests() {
        let handler = TestRequestHandler()
        TestService.startHandlingAllRequests(handler: handler)

        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })
        XCTAssertEqual(handler.dataRequests.count, 1)
        XCTAssertEqual(handler.dataRequests[0].url?.absoluteString, "https://example.com/empty")
        XCTAssertEqual(handler.dataRequests[0].httpMethod, "GET")

        // Should intercept all instances of TestServicehttps://example.com/empty
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(to: TestService(errorConfiguring: false)), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })

        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"") })
        XCTAssertEqual(handler.downloadRequests.count, 1)
        XCTAssertEqual(handler.downloadRequests[0].url?.absoluteString, "https://example.com/out")
        XCTAssertEqual(handler.downloadRequests[0].httpMethod, "GET")
    }
}

public class TestRequestHandler: RequestHandler {
    var dataRequests = [URLRequest]()
    var downloadRequests = [URLRequest]()

    public func handle(dataRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        self.dataRequests.append(dataRequest)
        return (nil, nil, nil)
    }

    public func handle(downloadRequest: URLRequest) -> (URL?, URLResponse?, Error?) {
        self.downloadRequests.append(downloadRequest)
        return (nil, nil, nil)
    }
}
