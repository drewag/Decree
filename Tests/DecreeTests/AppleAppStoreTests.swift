//
//  AppleAppStoreTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/22/19.
//

import XCTest
import Decree

class AppleAppStoreTests: XCTestCase {
    let session = TestURLSession()
    typealias Status = Apple.AppStore.Status
    typealias Verify = Apple.AppStore.VerifyReceipt

    let receiptData = Verify.Input(receiptData: "RECEIPT_DATA".data(using: .utf8)!)

    override func setUp() {
        super.setUp()

        self.session.startedTasks.removeAll()
        Apple.AppStore.shared.sessionOverride = self.session
    }

    func testVerifyInput() throws {
        Verify().makeRequest(with: receiptData) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://buy.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, #"{"receipt-data":"UkVDRUlQVF9EQVRB"}"#)
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func testRedirectToTest() {
        Verify().makeRequest(with: receiptData) { _ in }

        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://buy.itunes.apple.com/verifyReceipt")
        self.session.startedTasks.last!.complete(Status.receiptIsTest.responseData, TestResponse(), nil)

        // Should automatically send a new request to the sandbox
        XCTAssertEqual(self.session.startedTasks.last!.request.url?.absoluteString, "https://sandbox.itunes.apple.com/verifyReceipt")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpMethod, "POST")
        XCTAssertEqual(self.session.startedTasks.last!.request.httpBody?.string, #"{"receipt-data":"UkVDRUlQVF9EQVRB"}"#)
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(self.session.startedTasks.last!.request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }

    func testHappyPaht() throws {
        let data = "{\n\"receipt\":{\"receipt_type\":\"ProductionSandbox\", \"adam_id\":0, \"app_item_id\":0, \"bundle_id\":\"com.app.bundle.id\", \"application_version\":\"70\", \"download_id\":0, \"version_external_identifier\":0, \"receipt_creation_date\":\"2019-07-23 05:47:05 Etc/GMT\", \"receipt_creation_date_ms\":\"1563860825000\", \"receipt_creation_date_pst\":\"2019-07-22 22:47:05 America/Los_Angeles\", \"request_date\":\"2019-07-23 06:32:23 Etc/GMT\", \"request_date_ms\":\"1563863543248\", \"request_date_pst\":\"2019-07-22 23:32:23 America/Los_Angeles\", \"original_purchase_date\":\"2013-08-01 07:00:00 Etc/GMT\", \"original_purchase_date_ms\":\"1375340400000\", \"original_purchase_date_pst\":\"2013-08-01 00:00:00 America/Los_Angeles\", \"original_application_version\":\"1.0\", \n\"in_app\":[\n{\"quantity\":\"1\", \"product_id\":\"product1\", \"transaction_id\":\"1000000999999999\", \"original_transaction_id\":\"1000000888888888\", \"purchase_date\":\"2019-07-23 05:47:05 Etc/GMT\", \"purchase_date_ms\":\"1563860825000\", \"purchase_date_pst\":\"2019-07-22 22:47:05 America/Los_Angeles\", \"original_purchase_date\":\"2019-07-23 05:47:05 Etc/GMT\", \"original_purchase_date_ms\":\"1563860825000\", \"original_purchase_date_pst\":\"2019-07-22 22:47:05 America/Los_Angeles\", \"is_trial_period\":\"false\"}]}, \"status\":0, \"environment\":\"Sandbox\"}".data(using: .utf8)!
        self.session.fixedOutput = (data: data, response: TestResponse(), error: nil)
        let output = try Verify().makeSynchronousRequest(with: receiptData)

        XCTAssertEqual(output.receipt.inApp.count, 1)
        XCTAssertEqual(output.receipt.inApp[0].quantity, 1)
        XCTAssertEqual(output.receipt.inApp[0].productId, "product1")
        XCTAssertEqual(output.receipt.inApp[0].transactionId, "1000000999999999")
        XCTAssertEqual(output.receipt.inApp[0].purchaseDate.timeIntervalSince1970, 1563860825.0)
        XCTAssertEqual(output.receipt.inApp[0].originalPurchaseDate?.timeIntervalSince1970, 1563860825.0)
    }

    func testOutputErrors() throws {
        self.session.fixedOutput = (data: Status.unreadable.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "The App Store could not read the JSON object you provided.")})

        self.session.fixedOutput = (data: Status.malformed.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "The data in the receipt-data property was malformed or missing.")})

        self.session.fixedOutput = (data: Status.notAuthenticated.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "The receipt could not be authenticated.")})

        self.session.fixedOutput = (data: Status.invalidSharedSecret.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "The shared secret you provided does not match the shared secret on file for your account.")})

        self.session.fixedOutput = (data: Status.serverUnavailable.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "The receipt server is not currently available.")})

        self.session.fixedOutput = (data: Status.subscriptionExpired.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "This receipt is valid but the subscription has expired.")})

        self.session.fixedOutput = (data: Status.receiptIsProduction.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.")})

        self.session.fixedOutput = (data: Status.unauthrozized.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "This receipt could not be authorized. Treat this the same as if a purchase was never made.")})

        // Output Parsing

        self.session.fixedOutput = (data: Status.success.responseData, response: TestResponse(), error: nil)
        XCTAssertThrowsError(try Verify().makeSynchronousRequest(with: receiptData), "", { XCTAssertEqual($0.localizedDescription, "Error decoding Output")})
    }

    func testCoding() throws {
        let date1 = Date(timeIntervalSince1970: -14182980)
        let date2 = Date(timeIntervalSince1970: -14182981)

        let inApp = Apple.AppStore.Receipt.InApp(
            quantity: 1,
            productId: "PRODUCT",
            transactionId: "TRANSACTION",
            purchaseDate: date1,
            originalPurchaseDate: date2
        )

        let data = try JSONEncoder().encode(inApp)
        let out = try JSONDecoder().decode(Apple.AppStore.Receipt.InApp.self, from: data)
        XCTAssertEqual(out.quantity, 1)
        XCTAssertEqual(out.productId, "PRODUCT")
        XCTAssertEqual(out.transactionId, "TRANSACTION")
        XCTAssertEqual(out.purchaseDate.timeIntervalSince1970, -14182980)
        XCTAssertEqual(out.originalPurchaseDate?.timeIntervalSince1970, -14182981)
    }
}

private extension Apple.AppStore.Status {
    var responseData: Data {
        return #"{"status":\#(self.rawValue)}"#.data(using: .utf8)!
    }
}
