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

    struct ErrorResponse: AnyErrorResponse {
        let message: String
    }

    static var shared = TestService(errorConfiguring: false)
    static var sharedErrorConfiguring = TestService(errorConfiguring: true)

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
        request.addValue("VALUE", forHTTPHeaderField: "Test")
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

struct Empty: EmptyEndpoint {
    typealias Service = TestService
    static let method = Method.get

    let path = "empty"
}

struct Out: OutEndpoint {
    typealias Service = TestService
    static let method = Method.get

    typealias Output = TestOutput

    let path = "out"
}

struct In: InEndpoint {
    typealias Service = TestService
    static let method = Method.put

    typealias Input = TestInput
    static let inputFormat = InputFormat.JSON

    let path = "in"
}

struct InOut: InOutEndpoint {
    typealias Service = TestService
    static let method = Method.post

    typealias Input = TestInput
    static let inputFormat = InputFormat.JSON

    typealias Output = TestOutput

    let path = "inout"
}

struct URLQueryIn: InEndpoint {
    typealias Service = TestService
    static let method = Method.put

    typealias Input = TestInput
    static let inputFormat = InputFormat.urlQuery

    let path = "in"
}

struct URLQueryInOut: InOutEndpoint {
    typealias Service = TestService
    static let method = Method.post

    typealias Input = TestInput
    static let inputFormat = InputFormat.urlQuery

    typealias Output = TestOutput

    let path = "inout"
}

struct TestInput: Encodable {
    let date: Date?
    let string = "weird&=?characters"
    let otherError: Bool

    enum CodingKeys: String, CodingKey {
        case date
        case string
    }

    init(date: Date?, otherError: Bool = false) {
        self.date = date
        self.otherError = otherError
    }

    func encode(to encoder: Swift.Encoder) throws {
        guard !otherError else {
            throw RequestError.custom("other encoding error")
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        guard let date = self.date else {
            let context = EncodingError.Context(codingPath: [], debugDescription: "nil date")
            throw EncodingError.invalidValue(self.date as Any, context)
        }
        try container.encode(date, forKey: .date)
        try container.encode(self.string, forKey: .string)
    }
}

struct TestOutput: Decodable {
    let date: Date
}
