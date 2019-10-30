//
//  KeyValueEncoder.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

//
//  DataDictEncoder.swift
//  EdSuite
//
//  Created by Andrew J Wagner on 5/31/19.
//

import Foundation

/// Encode to key value pairs
public class KeyValueEncoder: Encoder {
    enum Value: Equatable {
        case none
        case string(String)
        case data(Data)
        case bool(Bool)
        case file(File)
    }

    public let codingPath: [CodingKey]
    var values = [(String,Value)]()
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Defer to `Date` for choosing an encoding. This is the default strategy.
        case deferredToDate

        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970

        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)
    }

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    public var dateEncodingStrategy = DateEncodingStrategy.deferredToDate

    /// The strategy to use for encoding arrays.
    public enum ArrayEncodingStrategy {
        /// Repeat the key with brackets (`[]`) for every element in the array. This is the default strategy.
        case repetitionWithBrackets

        /// Repeat the key for every element in the array
        case repetition
    }

    /// The strategy to use for encoding arrays. Defaults to `.repetitionWithBrackets`.
    public var arrayEncodingStrategy = ArrayEncodingStrategy.repetitionWithBrackets

    init(codingPath: [CodingKey] = [], template: KeyValueEncoder? = nil) {
        self.codingPath = codingPath
        if let template = template {
            self.userInfo = template.userInfo
            self.arrayEncodingStrategy = template.arrayEncodingStrategy
            self.dateEncodingStrategy = template.dateEncodingStrategy
        }
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        guard let key = self.codingPath.last else {
            fatalError("single value containers at root are not supported")
        }
        return KeyValueSingleValueEncodingContainer(encoder: self, key: key)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not supported")
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(KeyValueKeyedEncodingContainer(encoder: self))
    }
}

private class KeyValueKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: KeyValueEncoder
    let codingPath: [CodingKey] = []

    init(encoder: KeyValueEncoder) {
        self.encoder = encoder
    }

    func superEncoder() -> Swift.Encoder {
        return self.encoder
    }

    func superEncoder(forKey key: Key) -> Swift.Encoder {
        return self.encoder
    }

    func encodeNil(forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .none))
    }

    func encode(_ value: Int, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Bool, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .bool(value)))
    }

    func encode(_ value: Float, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Double, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: String, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string(value)))
    }

    func encode(_ date: Date, forKey key: Key) throws {
        switch self.encoder.dateEncodingStrategy {
        case .deferredToDate:
            let encoder = KeyValueEncoder(codingPath: [key], template: self.encoder)
            try date.encode(to: encoder)
            self.encoder.values += encoder.values
        case .secondsSince1970:
            try self.encode(Int(round(date.timeIntervalSince1970)), forKey: key)
        case .millisecondsSince1970:
            try self.encode(Int(round(date.timeIntervalSince1970 * 1000)), forKey: key)
        case .formatted(let formatter):
            try self.encode(formatter.string(from: date), forKey: key)
        }
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Swift.Encodable {
        guard !(Mirror(reflecting: value).displayStyle == .optional) else {
            let encoder = KeyValueEncoder(codingPath: self.encoder.codingPath + [key], template: self.encoder)
            try value.encode(to: encoder)
            self.encoder.values += encoder.values
            return
        }

        if let file = value as? File {
            self.encoder.values.append((key.stringValue, .file(file)))
        }
        else if let date = value as? Date {
            try self.encode(date, forKey: key)
        }
        else if let data = value as? Data {
            self.encoder.values.append((key.stringValue, .data(data)))
        }
        else if let array = value as? Array<Encodable> {
            for value in array {
                let rawKey: String
                switch self.encoder.arrayEncodingStrategy {
                case .repetitionWithBrackets:
                    rawKey = key.stringValue + "[]"
                case .repetition:
                    rawKey = key.stringValue
                }

                if let file = value as? File {
                    self.encoder.values.append((rawKey, .file(file)))
                    continue
                }
                let encoder = KeyValueEncoder(codingPath: [key], template: self.encoder)
                try value.encode(to: encoder)
                guard let first = encoder.values.first else {
                    continue
                }
                self.encoder.values.append((rawKey, first.1))
            }
        }
        else {
            let encoder = KeyValueEncoder(codingPath: [key], template: self.encoder)
            try value.encode(to: encoder)
            self.encoder.values += encoder.values
        }
    }

    func encode(_ value: Int8, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int16, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int32, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int64, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
        self.encoder.values.append((key.stringValue, .string("\(value)")))
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("encoding a nested container is not supported")
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("encoding nested values is not supported")
    }
}

private class KeyValueSingleValueEncodingContainer: SingleValueEncodingContainer {
    let key: CodingKey
    let encoder: KeyValueEncoder
    let codingPath: [CodingKey] = []

    init(encoder: KeyValueEncoder, key: CodingKey) {
        self.key = key
        self.encoder = encoder
    }

    func encodeNil() throws {
        self.encoder.values.append((self.key.stringValue, .none))
    }

    func encode(_ value: Bool) throws {
        self.encoder.values.append((self.key.stringValue, .bool(value)))
    }

    func encode(_ value: Int) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int8) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int16) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int32) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Int64) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt8) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt16) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt32) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: UInt64) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Float) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: Double) throws {
        self.encoder.values.append((self.key.stringValue, .string("\(value)")))
    }

    func encode(_ value: String) throws {
        self.encoder.values.append((self.key.stringValue, .string(value)))
    }

    func encode(_ date: Date) throws {
        switch self.encoder.dateEncodingStrategy {
        case .deferredToDate:
            let encoder = KeyValueEncoder(codingPath: [key], template: self.encoder)
            try date.encode(to: encoder)
            self.encoder.values += encoder.values
        case .secondsSince1970:
            try self.encode(Int(round(date.timeIntervalSince1970)))
        case .millisecondsSince1970:
            try self.encode(Int(round(date.timeIntervalSince1970 * 1000)))
        case .formatted(let formatter):
            try self.encode(formatter.string(from: date))
        }
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        guard !(Mirror(reflecting: value).displayStyle == .optional) else {
            let encoder = KeyValueEncoder(codingPath: self.encoder.codingPath + [self.key], template: self.encoder)
            try value.encode(to: encoder)
            self.encoder.values += encoder.values
            return
        }

        if let file = value as? File {
            self.encoder.values.append((self.key.stringValue, .file(file)))
        }
        else if let date = value as? Date {
            try self.encode(date)
        }
        else if let data = value as? Data {
            self.encoder.values.append((self.key.stringValue, .data(data)))
        }
        else if let array = value as? Array<Encodable> {
            for value in array {
                let rawKey: String
                switch self.encoder.arrayEncodingStrategy {
                case .repetitionWithBrackets:
                    rawKey = key.stringValue + "[]"
                case .repetition:
                    rawKey = key.stringValue
                }

                if let file = value as? File {
                    self.encoder.values.append((rawKey, .file(file)))
                    continue
                }
                let encoder = KeyValueEncoder(codingPath: [key], template: self.encoder)
                try value.encode(to: encoder)
                guard let first = encoder.values.first else {
                    continue
                }
                self.encoder.values.append((rawKey, first.1))
            }
        }
        else {
            let encoder = KeyValueEncoder(codingPath: self.encoder.codingPath + [self.key], template: self.encoder)
            try value.encode(to: encoder)
            self.encoder.values += encoder.values
        }
    }
}
