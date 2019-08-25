//
//  ProgressTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 8/24/19.
//

import XCTest
import Decree

class ProgressTests: MakeRequestTestCase {
    @available(iOS 11.0, OSX 10.13, *)
    func testEmptyProgress() {
        var progress: Double = 1
        var result: EmptyResult?
        Empty().makeRequest(
            callbackQueue: nil,
            onProgress: { newProgress in
                progress = newProgress
            },
            onComplete: { r in
                result = r
            }
        )
        XCTAssertEqual(progress, 0)
        XCTAssertNil(result)

        self.session.startedTasks[0].progress._factionCompleted = 0.1
        XCTAssertEqual(progress, 0.1)
        XCTAssertNil(result)
        self.session.startedTasks[0].progress._factionCompleted = 0.2
        XCTAssertEqual(progress, 0.2)
        XCTAssertNil(result)

        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertEqual(progress, 1)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
    }

    @available(iOS 11.0, OSX 10.13, *)
    func testOutRequestFlow() {
        var progress: Double = 1
        var result: Result<Out.Output, DecreeError>?
        Out().makeRequest(
            callbackQueue: nil,
            onProgress: { newProgress in
                progress = newProgress
            },
            onComplete: { r in
                result = r
            }
        )
        XCTAssertEqual(progress, 0)
        XCTAssertNil(result)

        self.session.startedTasks[0].progress._factionCompleted = 0.1
        XCTAssertEqual(progress, 0.1)
        XCTAssertNil(result)
        self.session.startedTasks[0].progress._factionCompleted = 0.2
        XCTAssertEqual(progress, 0.2)
        XCTAssertNil(result)

        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }

    @available(iOS 11.0, OSX 10.13, *)
    func testInRequestFlow() {
        var progress: Double = 1
        var result: EmptyResult?
        In().makeRequest(
            with: .init(date: date),
            callbackQueue: nil,
            onProgress: { newProgress in
                progress = newProgress
            },
            onComplete: { r in
                result = r
            }
        )
        XCTAssertEqual(progress, 0)
        XCTAssertNil(result)

        self.session.startedTasks[0].progress._factionCompleted = 0.1
        XCTAssertEqual(progress, 0.1)
        XCTAssertNil(result)
        self.session.startedTasks[0].progress._factionCompleted = 0.2
        XCTAssertEqual(progress, 0.2)
        XCTAssertNil(result)

        self.session.startedTasks[0].complete(successData, TestResponse(), nil)
        XCTAssertNotNil(result)
        XCTAssertNil(result?.error)
    }

    @available(iOS 11.0, OSX 10.13, *)
    func testInOutRequestFlow() {
        var progress: Double = 1
        var result: Result<InOut.Output, DecreeError>?
        InOut().makeRequest(
            with: .init(date: date),
            callbackQueue: nil,
            onProgress: { newProgress in
                progress = newProgress
            },
            onComplete: { r in
                result = r
            }
        )
        XCTAssertEqual(progress, 0)
        XCTAssertNil(result)

        self.session.startedTasks[0].progress._factionCompleted = 0.1
        XCTAssertEqual(progress, 0.1)
        XCTAssertNil(result)
        self.session.startedTasks[0].progress._factionCompleted = 0.2
        XCTAssertEqual(progress, 0.2)
        XCTAssertNil(result)

        self.session.startedTasks[0].complete(validOutData, TestResponse(), nil)
        XCTAssertEqual(result?.output?.date.timeIntervalSince1970, -14182980)
    }
}
