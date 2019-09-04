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
    let url = URL(string: "http://example.com")!
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

        let pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: Empty.self,
            validatingPath: { path in
                XCTAssertEqual(path, "empty")
                pathCalled.fulfill()
            },
            andReturn: .success
        )
        XCTAssertNoThrow(try Empty().makeSynchronousRequest())
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: Empty.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            andReturn: .success
        )
        XCTAssertThrowsError(try Empty().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error emptying: An internal error has occured. If it continues, please contact support with the description \"other\"") })
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

        var pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                XCTAssertEqual(path, "in")
                pathCalled.fulfill()
            },
            receiving: .init(date: date)
        )
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            receiving: .init(date: date)
        )
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                XCTAssertEqual(path, "in")
                pathCalled.fulfill()
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                XCTAssertEqual(path, "in")
                pathCalled.fulfill()
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success
            }
        )
        XCTAssertNoThrow(try In().makeSynchronousRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: In.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success
            }
        )
        XCTAssertThrowsError(try In().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inning: An internal error has occured. If it continues, please contact support with the description \"other\"") })
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

        let pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: Out.self,
            validatingPath: { path in
                XCTAssertEqual(path, "out")
                pathCalled.fulfill()
            },
            andReturn: .success(TestOutput(date: date))
        )
        XCTAssertNoThrow(try Out().makeSynchronousRequest())
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: Out.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            andReturn: .success(TestOutput(date: date))
        )
        XCTAssertThrowsError(try Out().makeSynchronousRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"other\"") })
    }

    func testOutDownloadMocking() throws {
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ during mocking that was not expected.") })

        self.mock.expectDownload(Out(), andReturn: .success(url))
        XCTAssertEqual(try Out().makeSynchronousDownloadRequest().absoluteString, "http://example.com")

        self.mock.expectDownload(Out(), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expectDownload(InOut(), receiving: .init(date: nil), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ when ‘InOut’ was expected.") })

        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: A request was made to ‘Out’ during mocking that was not expected.") })

        let pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpointDownload(
            ofType: Out.self,
            validatingPath: { path in
                XCTAssertEqual(path, "out")
                pathCalled.fulfill()
            },
            andReturn: .success(url)
        )
        XCTAssertNoThrow(try Out().makeSynchronousDownloadRequest())
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpointDownload(
            ofType: Out.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            andReturn: .success(url)
        )
        XCTAssertThrowsError(try Out().makeSynchronousDownloadRequest(), "", { XCTAssertEqual($0.localizedDescription, "Error outing: An internal error has occured. If it continues, please contact support with the description \"other\"") })
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

        var pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            receiving: .init(date: date),
            andReturn: .success(.init(date: date))
        )
        XCTAssertNoThrow(try InOut().makeSynchronousRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            receiving: .init(date: date),
            andReturn: .success(.init(date: date))
        )
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success(TestOutput(date: self.date))
            }
        )
        XCTAssertNoThrow(try InOut().makeSynchronousRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpoint(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success(TestOutput(date: self.date))
            }
        )
        XCTAssertThrowsError(try InOut().makeSynchronousRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })
    }

    func testInOutDownloadMocking() throws {
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ during mocking that was not expected.") })

        self.mock.expectDownload(InOut(), receiving: .init(date: date), andReturn: .success(url))
        XCTAssertEqual(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)).absoluteString, "http://example.com")

        self.mock.expectDownload(InOut(), receiving: .init(date: date), andReturn: .failure(DecreeError(.unauthorized)))
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expectDownload(InOut(), receiving: .init(date: otherDate), andReturn: .success(url))
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ with unexpected input.") })

        self.mock.expectDownload(InOut(), throwingError: DecreeError(.unauthorized))
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expectDownload(InOut(), validatingInput: { _ in return .failure(DecreeError(.unauthorized)) })
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expectDownload(InOut(), validatingInput: { input in
            XCTAssertEqual(input.date, self.date)
            return .success(self.url)
        })
        XCTAssertEqual(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)).absoluteString, "http://example.com")

        self.mock.expectDownload(InOut(), validatingInput: { input in
            XCTAssertEqual(input.date, self.date)
            return .failure(DecreeError(.unauthorized))
        })
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })

        self.mock.expectDownload(Out(), andReturn: .success(url))
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ when ‘Out’ was expected.") })

        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: A request was made to ‘InOut’ during mocking that was not expected.") })

        var pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            receiving: .init(date: date),
            andReturn: .success(url)
        )
        XCTAssertNoThrow(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            receiving: .init(date: date),
            andReturn: .success(url)
        )
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error making request: You are not logged in.") })
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            throwingError: DecreeError(.unauthorized)
        )
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })

        pathCalled = expectation(description: "validating path called")
        pathCalled.assertForOverFulfill = true
        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                XCTAssertEqual(path, "inout")
                pathCalled.fulfill()
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success(self.url)
            }
        )
        XCTAssertNoThrow(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)))
        wait(for: [pathCalled], timeout: 0)

        self.mock.expectEndpointDownload(
            ofType: InOut.self,
            validatingPath: { path in
                throw OtherError("other")
            },
            validatingInput: { input in
                XCTAssertEqual(input.date, self.date)
                return .success(self.url)
            }
        )
        XCTAssertThrowsError(try InOut().makeSynchronousDownloadRequest(with: .init(date: date)), "", { XCTAssertEqual($0.localizedDescription, "Error inouting: An internal error has occured. If it continues, please contact support with the description \"other\"") })
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
        let expectation = EmptyExpectation<Empty>(pathValidation: { _ in }, returning: .success)

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

    func testWaiting() {
        let queue = DispatchQueue(label: "back")

        var callbackCalled = false
        var expectation: AnyExpectation = self.mock.expect(Empty(), andReturn: .success)
        Empty().makeRequest(callbackQueue: queue) { _ in
            callbackCalled = true
        }
        XCTAssertEqual(expectation.wait(timeout: 5), .success)
        XCTAssertTrue(callbackCalled)

        callbackCalled = false
        expectation = self.mock.expect(In(), receiving: .init(date: date))
        In().makeRequest(with: .init(date: date), callbackQueue: queue) { _ in
            callbackCalled = true
        }
        XCTAssertEqual(expectation.wait(timeout: 5), .success)
        XCTAssertTrue(callbackCalled)

        callbackCalled = false
        expectation = self.mock.expect(Out(), andReturn: .success(.init(date: date)))
        Out().makeRequest(callbackQueue: queue) { _ in
            callbackCalled = true
        }
        XCTAssertEqual(expectation.wait(timeout: 5), .success)
        XCTAssertTrue(callbackCalled)

        callbackCalled = false
        expectation = self.mock.expect(InOut(), receiving: .init(date: date), andReturn: .success(.init(date: date)))
        InOut().makeRequest(with: .init(date: date), callbackQueue: queue) { _ in
            callbackCalled = true
        }
        XCTAssertEqual(expectation.wait(timeout: 5), .success)
        XCTAssertTrue(callbackCalled)
    }
}
