//
//  AppleAppStore.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

public struct Apple {
    public struct AppStore: WebService {
        public struct BasicResponse: Decodable {
            public let status: Status
        }
        public typealias ErrorResponse = NoErrorResponse

        public static var shared = AppStore()
        public var sessionOverride: Session? = nil

        public let baseURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!

        public func validate<E: Endpoint>(_ response: BasicResponse, for endpoint: E) throws {
            switch response.status {
            case .success:
                break
            case .receiptIsTest:
                throw ReceiptIsTestError()
            default:
                throw ResponseError.custom(response.status.description)
            }
        }

        public func handle<E: Endpoint>(_ error: ErrorKind, response: URLResponse, from endpoint: E) -> ErrorHandling {
            let sandboxURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!

            switch error {
            case .plain(let plain) where plain is ReceiptIsTestError:
                return .redirect(to: sandboxURL)
            default:
                return .none
            }
        }
    }
}

extension Apple.AppStore {
    public struct VerifyReceipt: InOutEndpoint {
        public typealias Service = Apple.AppStore

        public static let method = Method.post
        public let path = ""

        public struct Input: Encodable {
            enum CodingKeys: String, CodingKey { case receiptData = "receipt-data" }
            public let receiptData: Data

            public init(receiptData: Data) {
                self.receiptData = receiptData
            }
        }

        public struct Output: Decodable {
            public let receipt: Receipt
        }

        public init() {}
    }

    public enum Status: Int, Codable {
        case success = 0
        case unreadable = 21000
        case malformed = 21002
        case notAuthenticated = 21003
        case invalidSharedSecret = 21004
        case serverUnavailable = 21005
        case subscriptionExpired = 21006
        case receiptIsTest = 21007
        case receiptIsProduction = 21008
        case unauthrozized = 21010
    }

    public struct Receipt: Codable {
        enum CodingKeys: String, CodingKey {
            case inApp = "in_app"
        }

        public struct InApp {
            public let quantity: Int
            public let productId: String
            public let transactionId: String
            public let purchaseDate: Date
            public let originalPurchaseDate: Date?

            public init(quantity: Int = 1, productId: String, transactionId: String, purchaseDate: Date? = nil, originalPurchaseDate: Date? = nil) {
                self.quantity = quantity
                self.productId = productId
                self.transactionId = transactionId
                self.purchaseDate = purchaseDate ?? Date.now
                self.originalPurchaseDate = originalPurchaseDate
            }
        }

        public let inApp: [InApp]
    }
}

extension Apple.AppStore.Receipt.InApp: Codable {
    enum CodingKeys: String, CodingKey {
        case quantity
        case productId = "product_id"
        case transactionId = "transaction_id"
        case purchaseDate = "purchase_date_ms"
        case originalPurchaseDate = "original_purchase_date_ms"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.quantity = Int(try container.decode(String.self, forKey: .quantity)) ?? 0
        self.productId = try container.decode(String.self, forKey: .productId)
        self.transactionId = try container.decode(String.self, forKey: .transactionId)

        guard let purchaseMs = Int(try container.decode(String.self, forKey: .purchaseDate)) else {
            throw DecodingError.dataCorruptedError(forKey: .purchaseDate, in: container, debugDescription: "invalid date")
        }
        self.purchaseDate = Date(timeIntervalSince1970: TimeInterval(purchaseMs / 1000))

        if let originalMsString = try container.decodeIfPresent(String.self, forKey: .originalPurchaseDate) {
            guard let originalMs = Int(originalMsString) else {
                throw DecodingError.dataCorruptedError(forKey: .originalPurchaseDate, in: container, debugDescription: "invalid date")
            }
            self.originalPurchaseDate = Date(timeIntervalSince1970: TimeInterval(originalMs / 1000))
        }
        else {
            self.originalPurchaseDate = nil
        }
    }


    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("\(self.quantity)", forKey: .quantity)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.transactionId, forKey: .transactionId)
        try container.encode("\(Int(self.purchaseDate.timeIntervalSince1970 * 1000))", forKey: .purchaseDate)
        if let date = self.originalPurchaseDate {
            try container.encode("\(Int(date.timeIntervalSince1970 * 1000))", forKey: .originalPurchaseDate)
        }
    }
}

extension Apple.AppStore.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success:
            return "Success"
        case .unreadable:
            return "The App Store could not read the JSON object you provided."
        case .malformed:
            return "The data in the receipt-data property was malformed or missing."
        case .notAuthenticated:
            return "The receipt could not be authenticated."
        case .invalidSharedSecret:
            return "The shared secret you provided does not match the shared secret on file for your account."
        case .serverUnavailable:
            return "The receipt server is not currently available."
        case .subscriptionExpired:
            return "This receipt is valid but the subscription has expired."
        case .receiptIsTest:
            return "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
        case .receiptIsProduction:
            return "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
        case .unauthrozized:
            return "This receipt could not be authorized. Treat this the same as if a purchase was never made."
        }
    }
}

private extension Apple.AppStore {
    struct ReceiptIsTestError: Error {}
}
