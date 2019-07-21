//
//  TestNoStandardsService.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import DeclarativeHTTPRequests

struct TestNoStandardsService: WebService {
    typealias BasicResponse = NoBasicResponse
    typealias ErrorResponse = NoErrorResponse

    static var shared = TestNoStandardsService(errorConfiguring: false)
    static var sharedErrorConfiguring = TestNoStandardsService(errorConfiguring: true)

    let errorConfiguring: Bool

    init(errorConfiguring: Bool) {
        self.errorConfiguring = errorConfiguring
    }

    var sessionOverride: Session? {
        return TestURLSession.test
    }

    var baseURL: URL { return URL(string: "https://example.com")! }

    func configure(_ request: inout URLRequest) throws {
        guard !errorConfiguring else {
            throw RequestError.custom("error configuring")
        }
        request.setValue("VALUE", forHTTPHeaderField: "Test")
    }

    func configure(_ encoder: inout JSONEncoder) throws {
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    func configure(_ decoder: inout JSONDecoder) throws {
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    func validate<E>(_ response: URLResponse, for endpoint: E) throws where E : Endpoint {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode != 201 else {
            throw RequestError.custom("Bad status code: \(statusCode)")
        }
    }

    func validate<E>(_ response: NoBasicResponse, for endpoint: E) throws where E : Endpoint {}
}

struct NoStandardInOut: InOutEndpoint {
    typealias Service = TestNoStandardsService
    static let method = Method.post

    typealias Input = TestInput
    static let inputFormat = InputFormat.JSON

    typealias Output = TestOutput

    let path = "inout"
}
