//
//  KeyValueEncoderTests.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import XCTest
@testable import Decree

class KeyValueEncoderTests: XCTestCase {
    func testEncodingObject() throws {
        let encoder = KeyValueEncoder(codingPath: [])
        try Object().encode(to: encoder)

        XCTAssertEqual(encoder.values.count, 36)

        XCTAssertTrue(encoder.values.contains(where: { $0 == "null" && $1 == nil}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "isTrue" && $1 == "true"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "isFalse" && $1 == "false"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "int" && $1 == "1"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "int8" && $1 == "2"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "int16" && $1 == "3"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "int32" && $1 == "4"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "int64" && $1 == "5"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "uint" && $1 == "6"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "uint8" && $1 == "7"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "uint16" && $1 == "8"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "uint32" && $1 == "9"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "uint64" && $1 == "10"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "float" && $1 == "11.12"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "double" && $1 == "13.14"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "string" && $1 == "some string"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "date" && $1 == "-14182980.0"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "data" && $1 == "c29tZSBkYXRh"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleNull" && $1 == nil}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleIsTrue" && $1 == "true"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleIsFalse" && $1 == "false"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleInt" && $1 == "1"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleInt8" && $1 == "2"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleInt16" && $1 == "3"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleInt32" && $1 == "4"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleInt64" && $1 == "5"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleUint" && $1 == "6"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleUint8" && $1 == "7"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleUint16" && $1 == "8"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleUint32" && $1 == "9"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleUint64" && $1 == "10"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleFloat" && $1 == "11.12"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleDouble" && $1 == "13.14"}))

        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleString" && $1 == "some string"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleDate" && $1 == "-14182980.0"}))
        XCTAssertTrue(encoder.values.contains(where: { $0 == "singleData" && $1 == "c29tZSBkYXRh"}))
    }
}

struct SingleValue<Value: Encodable>: Encodable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(self.value)
    }
}

struct Object: Encodable {
    let null: String? = nil

    let isTrue = true
    let isFalse = false

    let int: Int = 1
    let int8: Int8 = 2
    let int16: Int16 = 3
    let int32: Int32 = 4
    let int64: Int64 = 5

    let uint: UInt = 6
    let uint8: UInt8 = 7
    let uint16: UInt16 = 8
    let uint32: UInt32 = 9
    let uint64: UInt64 = 10

    let float: Float = 11.12
    let double: Double = 13.14

    let string: String = "some string"
    let date: Date = Date(timeIntervalSince1970: -14182980)
    let data: Data = "some data".data(using: .utf8)!

    let singleNull = SingleValue<String?>(nil)
    let singleIsTrue = SingleValue(true)
    let singleIsFalse = SingleValue(false)
    let singleInt = SingleValue<Int>(1)
    let singleInt8 = SingleValue<Int8>(2)
    let singleInt16 = SingleValue<Int16>(3)
    let singleInt32 = SingleValue<Int32>(4)
    let singleInt64 = SingleValue<Int64>(5)
    let singleUint = SingleValue<UInt>(6)
    let singleUint8 = SingleValue<UInt8>(7)
    let singleUint16 = SingleValue<UInt16>(8)
    let singleUint32 = SingleValue<UInt32>(9)
    let singleUint64 = SingleValue<UInt64>(10)
    let singleFloat = SingleValue<Float>(11.12)
    let singleDouble = SingleValue<Double>(13.14)
    let singleString = SingleValue("some string")
    let singleDate = SingleValue(Date(timeIntervalSince1970: -14182980))
    let singleData = SingleValue("some data".data(using: .utf8)!)

    enum CodingKeys: String, CodingKey {
        case null, isTrue, isFalse, int, int8, int16, int32, int64, uint, uint8, uint16, uint32, uint64, float, double, string, date, data
        case singleNull, singleIsTrue, singleIsFalse, singleInt, singleInt8, singleInt16, singleInt32, singleInt64, singleUint, singleUint8, singleUint16, singleUint32, singleUint64, singleFloat, singleDouble, singleString, singleDate, singleData

    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeNil(forKey: .null)
        try container.encode(self.isTrue, forKey: .isTrue)
        try container.encode(self.isFalse, forKey: .isFalse)
        try container.encode(self.int, forKey: .int)
        try container.encode(self.int8, forKey: .int8)
        try container.encode(self.int16, forKey: .int16)
        try container.encode(self.int32, forKey: .int32)
        try container.encode(self.int64, forKey: .int64)
        try container.encode(self.uint, forKey: .uint)
        try container.encode(self.uint8, forKey: .uint8)
        try container.encode(self.uint16, forKey: .uint16)
        try container.encode(self.uint32, forKey: .uint32)
        try container.encode(self.uint64, forKey: .uint64)
        try container.encode(self.float, forKey: .float)
        try container.encode(self.double, forKey: .double)
        try container.encode(self.string, forKey: .string)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.data, forKey: .data)

        try container.encode(self.singleNull, forKey: .singleNull)
        try container.encode(self.singleIsTrue, forKey: .singleIsTrue)
        try container.encode(self.singleIsFalse, forKey: .singleIsFalse)
        try container.encode(self.singleInt, forKey: .singleInt)
        try container.encode(self.singleInt8, forKey: .singleInt8)
        try container.encode(self.singleInt16, forKey: .singleInt16)
        try container.encode(self.singleInt32, forKey: .singleInt32)
        try container.encode(self.singleInt64, forKey: .singleInt64)
        try container.encode(self.singleUint, forKey: .singleUint)
        try container.encode(self.singleUint8, forKey: .singleUint8)
        try container.encode(self.singleUint16, forKey: .singleUint16)
        try container.encode(self.singleUint32, forKey: .singleUint32)
        try container.encode(self.singleUint64, forKey: .singleUint64)
        try container.encode(self.singleFloat, forKey: .singleFloat)
        try container.encode(self.singleDouble, forKey: .singleDouble)
        try container.encode(self.singleString, forKey: .singleString)
        try container.encode(self.singleDate, forKey: .singleDate)
        try container.encode(self.singleData, forKey: .singleData)
    }
}
