#if !canImport(ObjectiveC)
import XCTest

extension EmptyResultTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__EmptyResultTests = [
        ("testGettingError", testGettingError),
    ]
}

extension MakeRequestTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MakeRequestTests = [
        ("testEmpty", testEmpty),
        ("testEmptyRequestFlow", testEmptyRequestFlow),
        ("testIn", testIn),
        ("testInOut", testInOut),
        ("testInOutRequestFlow", testInOutRequestFlow),
        ("testInRequestFlow", testInRequestFlow),
        ("testOut", testOut),
        ("testOutRequestFlow", testOutRequestFlow),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EmptyResultTests.__allTests__EmptyResultTests),
        testCase(MakeRequestTests.__allTests__MakeRequestTests),
    ]
}
#endif
