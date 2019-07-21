//
//  Data+Helpers.swift
//  DeclarativeHTTPRequestsTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation
import XMLParsing

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }

    var jsonDict: [String:Raw] {
        let decoder = JSONDecoder()
        return (try? decoder.decode([String:Raw].self, from: self)) ?? [:]
    }

    var xmlDict: [String:Raw] {
        let decoder = XMLDecoder()
        return (try? decoder.decode([String:Raw].self, from: self)) ?? [:]
    }
}
