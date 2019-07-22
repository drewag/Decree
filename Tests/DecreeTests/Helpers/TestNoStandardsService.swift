//
//  TestNoStandardsService.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import Decree
import XMLCoder

struct TestNoStandardsService: WebService {
    typealias BasicResponse = NoBasicResponse
    typealias ErrorResponse = NoErrorResponse

    static let shared = TestNoStandardsService(errorConfiguring: false)
    static let sharedErrorConfiguring = TestNoStandardsService(errorConfiguring: true)

    let errorConfiguring: Bool

    init(errorConfiguring: Bool) {
        self.errorConfiguring = errorConfiguring
    }

    let sessionOverride: Session? = TestURLSession.test
    let baseURL = URL(string: "https://example.com")!

    func configure<E: Endpoint>(_ request: inout URLRequest, for endpoint: E) throws {
        guard !errorConfiguring else {
            throw RequestError.custom("error configuring")
        }
        request.setValue("VALUE", forHTTPHeaderField: "Test")
    }

    func configure<E: Endpoint>(_ encoder: inout JSONEncoder, for endpoint: E) throws {
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    func configure<E: Endpoint>(_ decoder: inout JSONDecoder, for endpoint: E) throws {
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    func configure<E: Endpoint>(_ encoder: inout XMLEncoder, for endpoint: E) throws {
        encoder.dateEncodingStrategy = .secondsSince1970
    }

    func configure<E: Endpoint>(_ decoder: inout XMLDecoder, for endpoint: E) throws {
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    func validate<E: Endpoint>(_ response: URLResponse, for endpoint: E) throws {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode != 201 else {
            throw RequestError.custom("Bad status code: \(statusCode)")
        }
    }
}

struct NoStandardInOut: InOutEndpoint {
    typealias Service = TestNoStandardsService
    static let method = Method.post

    typealias Input = TestInput

    typealias Output = TestOutput

    let path = "inout"
}
