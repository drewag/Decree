//
//  TestService.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation
import Decree
import XMLCoder

struct TestService: WebService {
    struct BasicResponse: Decodable {
        let success: Bool
    }

    struct ErrorResponse: AnyErrorResponse {
        let message: String
    }

    static let shared = TestService(errorConfiguring: false)
    static let sharedErrorConfiguring = TestService(errorConfiguring: true)

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
        request.addValue("VALUE", forHTTPHeaderField: "Test")
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

    struct Redirect: Error {}

    func validate<E: Endpoint>(_ response: URLResponse, for endpoint: E) throws {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard statusCode != 201 else {
            throw RequestError.custom("Bad status code: \(statusCode)")
        }
        guard statusCode != 299 else {
            throw Redirect()
        }
    }

    func validate<E: Endpoint>(_ response: BasicResponse, for endpoint: E) throws {
        guard response.success else {
            throw RequestError.custom("unsuccessful")
        }
    }

    func handle<E: Endpoint>(_ error: ErrorKind, response: URLResponse, from endpoint: E) -> ErrorHandling {
        switch error {
        case .plain(let plain) where plain is Redirect:
            return .redirect(to: URL(string: "https://example.com/redirected")!)
        default:
            return .none
        }
    }
}

struct Empty: EmptyEndpoint {
    typealias Service = TestService

    let path = "empty"
}

struct Out: OutEndpoint {
    typealias Service = TestService

    typealias Output = TestOutput

    let path = "out"
}

struct XMLOut: OutEndpoint {
    typealias Service = TestService

    typealias Output = TestOutput

    let path = "out"

    static let outputFormat = OutputFormat.XML
}

struct In: InEndpoint {
    typealias Service = TestService
    static let method = Method.put

    typealias Input = TestInput

    let path = "in"
}

struct InOut: InOutEndpoint {
    typealias Service = TestService
    static let method = Method.post

    typealias Input = TestInput

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

struct FormIn: InEndpoint {
    typealias Service = TestService
    static let method = Method.put

    typealias Input = TestInput
    static let inputFormat = InputFormat.formURLEncoded

    let path = "in"
}

struct FormInOut: InOutEndpoint {
    typealias Service = TestService
    static let method = Method.post

    typealias Input = TestInput
    static let inputFormat = InputFormat.formURLEncoded

    typealias Output = TestOutput

    let path = "inout"
}

struct XMLIn: InEndpoint {
    typealias Service = TestService
    static let method = Method.put

    typealias Input = TestInput
    static let inputFormat = InputFormat.XML(rootNode: "root")

    let path = "in"
}

struct XMLInOut: InOutEndpoint {
    typealias Service = TestService
    static let method = Method.post

    typealias Input = TestInput
    static let inputFormat = InputFormat.XML(rootNode: "root")

    typealias Output = TestOutput

    let path = "inout"
}

struct TestInput: Encodable {
    let date: Date?
    let string = "weird&=?<>characters"
    let otherError: Bool

    enum CodingKeys: String, CodingKey {
        case date
        case string
        case nullValue
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
        try container.encodeNil(forKey: .nullValue)
    }
}

struct TestOutput: Decodable {
    let date: Date
}
