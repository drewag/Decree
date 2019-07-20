//
//  TestService.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import DeclarativeHTTPRequests

struct TestService: WebService {
    struct BasicResponse: Decodable {
        let success: Bool
    }

    static var shared = TestService(errorConfiguring: false)
    static var sharedErrorConfiguring = TestService(errorConfiguring: true)

    let errorConfiguring: Bool

    init(errorConfiguring: Bool) {
        self.errorConfiguring = errorConfiguring
    }

    var sessionOverride: URLSession? {
        return TestURLSession.test
    }

    var baseURL: URL { return URL(string: "https://example.com")! }

    func configure(_ request: inout URLRequest) throws {
        guard !errorConfiguring else {
            throw RequestError.custom("error configuring")
        }
        request.addValue("VALUE", forHTTPHeaderField: "TEST")
    }

    func configure(_ encoder: inout JSONEncoder) throws {
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    func configure(_ decoder: inout JSONDecoder) throws {
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    func validate<E>(_ response: URLResponse, for endpoint: E) throws where E : Endpoint {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode >= 200 && statusCode < 300 else {
            throw RequestError.custom("Bad status code: \(statusCode)")
        }
    }

    func validate<E>(_ response: TestService.BasicResponse, for endpoint: E) throws where E : Endpoint {
        guard response.success else {
            throw RequestError.custom("unsuccessful")
        }
    }
}
