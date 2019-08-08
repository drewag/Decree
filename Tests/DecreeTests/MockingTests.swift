//
//  MockingTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 8/5/19.
//

import XCTest
@testable import Decree

class MockingTests: XCTestCase {
    let date = Date(timeIntervalSince1970: -14182980)
    let otherDate = Date(timeIntervalSince1970: -14182981)
    var mock: WebServiceMock<TestService>!

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

        self.mock.expect(In(), receiving: .init(date: date))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ when ‘In’ was expected.") })

        self.mock.expect(InOut(), receiving: .init(date: date), andReturn: .success(.init(date: date)))
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ when ‘InOut’ was expected.") })

        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: A request was made to ‘Empty’ during mocking that was not expected.") })
    }

    func testInMocking() {
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: A request was made to ‘In’ during mocking that was not expected.") })

        self.mock.expect(In(), receiving: .init(date: date))
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))

        self.mock.expect(In(), receiving: .init(date: otherDate))
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

        self.mock.expect(InOut(), receiving: .init(date: date), andReturn: .success(.init(date: date)))
        XCTAssertEqual(try InOut().makeSynchronousRequest(with: .init(date: date)).date, date)

        self.mock.expect(InOut(), receiving: .init(date: date), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expect(InOut(), receiving: .init(date: otherDate), andReturn: .success(.init(date: date)))
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

    func testInputEqualityTests() throws {
        let expectation = EmptyExpectation<Empty>(path: "", returning: .success)

        // Strings
        XCTAssertNoThrow(try expectation.validate(expected: "string", actual: "string", for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: "string1", actual: "string2", for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘string2’ but expected ‘string1’. A difference was found at the root.
            """
        )})

        // Data
        XCTAssertNoThrow(try expectation.validate(expected: "string".data(using: .utf8)!, actual: "string".data(using: .utf8)!, for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: "string1".data(using: .utf8)!, actual: "string2".data(using: .utf8)!, for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘7 bytes’ but expected ‘7 bytes’. A difference was found at the root.
            """
        )})

        // Number in JSON
        XCTAssertNoThrow(try expectation.validate(expected: [1], actual: [1], for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: [1,2], actual: [1,9], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘[1, 9]’ but expected ‘[1, 2]’. A difference was found at the path ‘1‘.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: [1.1,2.2], actual: [1.1,9.9], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘[1.1, 9.9]’ but expected ‘[1.1, 2.2]’. A difference was found at the path ‘1‘.
            """
        )})

        // Null in JSON
        XCTAssertNoThrow(try expectation.validate(expected: ["one",nil], actual: ["one",nil], for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: ["one",nil], actual: ["one","two"], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘[Optional("one"), Optional("two")]’ but expected ‘[Optional("one"), nil]’. A difference was found at the path ‘1‘.
            """
        )})

        // Dictionary
        XCTAssertNoThrow(try expectation.validate(expected: ["one": 1], actual: ["one": 1], for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: ["one": 1], actual: ["one": 9], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘["one": 9]’ but expected ‘["one": 1]’. A difference was found at the path ‘one‘.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: ["one": 1], actual: ["two": 1], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘["two": 1]’ but expected ‘["one": 1]’. A difference was found at the path ‘one‘.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: [["one": 1]], actual: [["two": 1]], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘[["two": 1]]’ but expected ‘[["one": 1]]’. A difference was found at the path ‘0.one‘.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: ["one": 1, "two": 2], actual: ["one": 1], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).reason, """
            A request was made to ‘Empty’ with unexpected input.
            """
        )})

        // Array
        XCTAssertNoThrow(try expectation.validate(expected: ["one","two"], actual: ["one","two"], for: Empty()))
        XCTAssertThrowsError(try expectation.validate(expected: ["one","two"], actual: ["one","two","three"], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘["one", "two", "three"]’ but expected ‘["one", "two"]’. A difference was found at the root.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: ["one","two"], actual: ["one","other"], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘["one", "other"]’ but expected ‘["one", "two"]’. A difference was found at the path ‘1‘.
            """
        )})
        XCTAssertThrowsError(try expectation.validate(expected: ["array": ["one","two"]], actual: ["array": ["one","other"]], for: Empty()), "", { XCTAssertEqual(($0 as! DecreeError).debugDescription, """
            Error Emptying: A request was made to ‘Empty’ with unexpected input.
            Got ‘["array": ["one", "other"]]’ but expected ‘["array": ["one", "two"]]’. A difference was found at the path ‘array.1‘.
            """
        )})
    }
}
