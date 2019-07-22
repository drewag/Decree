//
//  Decodable+Helpers.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

enum Raw: Decodable {
    case string(String)
    case interval(TimeInterval)
    case null

    var string: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var interval: TimeInterval? {
        switch self {
        case .interval(let interval):
            return interval
        default:
            return nil
        }
    }

    var isNil: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        guard !container.decodeNil() else {
            self = .null
            return
        }

        do {
            self = .interval(try container.decode(TimeInterval.self))
        }
        catch {
            self = .string(try container.decode(String.self))
        }
    }
}
