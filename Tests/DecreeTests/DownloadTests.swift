//
//  DownloadTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 9/3/19.
//

import XCTest
import Decree

class DownloadTests: MakeRequestTestCase {
    let outputURL = URL(string: "http://example.com")

    func testOutDownloadFlow() {
        var result: Result<URL, DecreeError>?

        Out().makeDownloadRequest(
            callbackQueue: nil,
            onComplete: { r in
                result = r
            }
        )
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedDownloadTasks.count, 1)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.httpMethod, "GET")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.httpBody, nil)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Content-Type"], nil)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.url?.absoluteString, "https://example.com/out")
        self.session.startedDownloadTasks[0].complete(outputURL, TestResponse(), nil)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(try result?.get().absoluteString, "http://example.com")
    }

    func testInOutDownloadFlow() {
        var result: Result<URL, DecreeError>?

        InOut().makeDownloadRequest(
            with: .init(date: date),
            callbackQueue: nil,
            onComplete: { r in
                result = r
        }
        )
        XCTAssertNil(result)

        XCTAssertEqual(self.session.startedDownloadTasks.count, 1)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.httpBody?.jsonDict["date"]?.interval, -14182980)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.httpBody?.jsonDict["string"]?.string, "weird&=?<>characters")
        XCTAssertTrue(self.session.startedDownloadTasks[0].request.httpBody?.jsonDict["nullValue"]?.isNil ?? false)
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.allHTTPHeaderFields?["Test"], "VALUE")
        XCTAssertEqual(self.session.startedDownloadTasks[0].request.url?.absoluteString, "https://example.com/inout")
        self.session.startedDownloadTasks[0].complete(outputURL, TestResponse(), nil)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
        XCTAssertEqual(try result?.get().absoluteString, "http://example.com")
    }

    func testOutDownload() {
        self.session.fixedDownloadOutput = (url: nil, response: nil, error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedDownloadOutput = (url: nil, response: nil, error: Out.error(reason:"custom"))
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedDownloadOutput = (url: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"No URL returned.\"")})

        self.session.fixedDownloadOutput = (url: outputURL, response: TestResponse(), error: nil)
        XCTAssertEqual(try Out().makeSynchronousDownloadRequest().absoluteString, "http://example.com")
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(to: .sharedErrorConfiguring), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }

    func testInOutDownload() {
        self.session.fixedDownloadOutput = (url: nil, response: nil, error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"No response returned.\"")})

        self.session.fixedDownloadOutput = (url: nil, response: nil, error: InOut.error(reason:"custom"))
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"custom\"")})

        self.session.fixedDownloadOutput = (url: nil, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"No URL returned.\"")})

        self.session.fixedDownloadOutput = (url: outputURL, response: TestResponse(), error: nil)
        XCTAssertEqual(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)).absoluteString, "http://example.com")

        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: nil)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"Failed to encode TestInput(date: nil, string: \"weird&=?<>characters\", otherError: false).\"")})
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date, otherError: true)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other encoding error\"")})
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(to: .sharedErrorConfiguring, with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"error configuring\"")})
    }
}

extension OutEndpoint {
    func makeSynchronousDownloadRequest(to service: Service = Service.shared) throws -> URL {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<URL, DecreeError>?
        self.makeDownloadRequest(to: service, callbackQueue: nil) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}

extension InOutEndpoint where Input: Encodable {
    func makeSynchronousDownloadRequest(to service: Service = Service.shared, with input: Input) throws -> URL {
        let semephore = DispatchSemaphore(value: 0)
        var result: Result<URL, DecreeError>?
        self.makeDownloadRequest(to: service, with: input, callbackQueue: nil) { output in
            result = output
            semephore.signal()
        }
        semephore.wait()

        switch result! {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}
