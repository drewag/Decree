//
//  MockingTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 8/5/19.
//

import XCTest
import Decree

class MockingTests: XCTestCase {
    let date = Date(timeIntervalSince1970: -14182980)
    let otherDate = Date(timeIntervalSince1970: -14182981)
    var mock: WebServiceMock!

    override func setUp() {
        self.mock = TestService.shared.startMocking()
    }

    override func tearDown() {
        TestService.shared.stopMocking()
    }

    func testEmptyMocking() {
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ during mocking that was not expected.") })

        self.mock.expect(Empty(), andReturn: .success)
        XCTAssertNoThrow(try Empty().makeSynchronousRequest())

        self.mock.expect(Empty(), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(Out(), andReturn: .success(TestOutput(date: date)))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ when ‘Out’ was expected.") })

        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ during mocking that was not expected.") })
    }

    func testInMocking() {
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: A request was made to ‘In’ during mocking that was not expected.") })

        self.mock.expect(In(), recieving: .init(date: date))
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))

        self.mock.expect(In(), recieving: .init(date: otherDate))
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: A request was made to ‘In’ with unexpected input.") })

        self.mock.expect(In(), throwingError: DecreeError(.unauthorized))
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(In(), validatingInput: { _ in return .failure(DecreeError(.unauthorized)) })
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(In(), validatingInput: { input in
            XCTAssertEqual(input.date, self.date)
            return .success
        })
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))

        self.mock.expect(Out(), andReturn: .success(TestOutput(date: date)))
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: A request was made to ‘In’ when ‘Out’ was expected.") })

        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: A request was made to ‘In’ during mocking that was not expected.") })
    }

    func testOutMocking() throws {
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ during mocking that was not expected.") })

        self.mock.expect(Out(), andReturn: .success(TestOutput(date: date)))
        XCTAssertEqual(try Out().makeSynchronousRequest().date, date)

        self.mock.expect(Out(), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(Empty(), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ when ‘Empty’ was expected.") })

        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ during mocking that was not expected.") })
    }

    func testInOutMocking() throws {
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ during mocking that was not expected.") })

        self.mock.expect(InOut(), recieving: .init(date: date), andReturn: .success(.init(date: date)))
        XCTAssertEqual(try InOut().makeSynchronousRequest(with: .init(date: date)).date, date)

        self.mock.expect(InOut(), recieving: .init(date: date), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(InOut(), recieving: .init(date: otherDate), andReturn: .success(.init(date: date)))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ with unexpected input.") })

        self.mock.expect(InOut(), throwingError: DecreeError(.unauthorized))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(InOut(), validatingInput: { _ in return .failure(DecreeError(.unauthorized)) })
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(InOut(), validatingInput: { input in
            XCTAssertEqual(input.date, self.date)
            return .success(.init(date: self.date))
        })
        XCTAssertEqual(try InOut().makeSynchronousRequest(with: .init(date: date)).date, date)

        self.mock.expect(InOut(), validatingInput: { input in
            XCTAssertEqual(input.date, self.date)
            return .failure(DecreeError(.unauthorized))
        })
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(Out(), andReturn: .success(TestOutput(date: date)))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ when ‘Out’ was expected.") })

        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ during mocking that was not expected.") })
    }

    func testMockingWithPath() throws {
        self.mock.expect(EmptyVariablePath(path: "empty"), andReturn: .success)
        XCTAssertNoThrow(try EmptyVariablePath(path: "empty").makeSynchronousRequest())

        self.mock.expect(EmptyVariablePath(path: "other"), andReturn: .success)
        XCTAssertThrowsError(try EmptyVariablePath(path: "empty").makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to the wrong path of ‘EmptyVariablePath’.") })
    }

    func testStartMockingAgain() throws {
        XCTAssertTrue(self.mock === TestService.shared.startMocking())
    }
}
