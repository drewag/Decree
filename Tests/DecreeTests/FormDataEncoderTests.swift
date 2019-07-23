//
//  FormDataEncoderTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/22/19.
//

import XCTest
@testable import Decree

class FormDataEncoderTests: XCTestCase {
    func testEncodeEmpty() {
        let values: [(String,KeyValueEncoder.Value)] = []

        let data = FormDataEncoder.encode(values)
        XCTAssertTrue(data.isEmpty)
    }

    func testEncodeString() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("key", .string("value")),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue--__DECREE_BOUNDARY__--")
    }

    func testEncodeBool() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("yes", .bool(true)),
            ("no", .bool(false)),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"yes\"\r\n\r\ntrue\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"no\"\r\n\r\nfalse--__DECREE_BOUNDARY__--")
    }

    func testEncodeNone() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("key", .none),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\n--__DECREE_BOUNDARY__--")
    }

    func testEncodeData() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("key", .data("value".data(using: .utf8)!)),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue--__DECREE_BOUNDARY__--")
    }

    func testEncodeFile() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("key", .file(File(name: "test.txt", content: "value".data(using: .utf8)!, type: .text))),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"key\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\nvalue--__DECREE_BOUNDARY__--")

    }

    func testEncodeAll() {
        let values: [(String,KeyValueEncoder.Value)] = [
            ("string", .string("value")),
            ("yes", .bool(true)),
            ("no", .bool(false)),
            ("none", .none),
            ("data", .data("value".data(using: .utf8)!)),
            ("file", .file(File(name: "test.txt", content: "value".data(using: .utf8)!, type: .text))),
        ]

        let data = FormDataEncoder.encode(values)
        XCTAssertEqual(data.string, "--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"string\"\r\n\r\nvalue\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"yes\"\r\n\r\ntrue\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"no\"\r\n\r\nfalse\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"none\"\r\n\r\n\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\nvalue\r\n--__DECREE_BOUNDARY__\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\nvalue--__DECREE_BOUNDARY__--")

    }
}
