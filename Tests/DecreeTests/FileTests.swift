//
//  FileTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/22/19.
//

import XCTest
import Decree

class FileTests: XCTestCase {
    func testText() {
        let file = File(name: "test.txt", text: "content")
        XCTAssertEqual(file.name, "test.txt")
        XCTAssertEqual(file.content, "content".data(using: .utf8)!)
        XCTAssertEqual(file.type, .text)
    }

    func testBinary() {
        let file = File(name: "test.bin", binary: "content".data(using: .utf8)!)
        XCTAssertEqual(file.name, "test.bin")
        XCTAssertEqual(file.content, "content".data(using: .utf8)!)
        XCTAssertEqual(file.type, .binary)
    }

    func testXML() {
        let file = File(name: "test.xml", xml: "<root>content</root>")
        XCTAssertEqual(file.name, "test.xml")
        XCTAssertEqual(file.content, "<root>content</root>".data(using: .utf8)!)
        XCTAssertEqual(file.type, .xml)
    }

    func testJSON() {
        let file = File(name: "test.json", json: #"{"root":"content"}"#)
        XCTAssertEqual(file.name, "test.json")
        XCTAssertEqual(file.content, #"{"root":"content"}"#.data(using: .utf8)!)
        XCTAssertEqual(file.type, .json)
    }

    func testJSONObject() throws {
        struct Object: Encodable {
            let root = "content"
        }
        let file = try File(name: "test.json", jsonObject: Object())
        XCTAssertEqual(file.name, "test.json")
        XCTAssertEqual(file.content, #"{"root":"content"}"#.data(using: .utf8)!)
        XCTAssertEqual(file.type, .json)

    }
}
