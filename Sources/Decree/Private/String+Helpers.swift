//
//  String+Helpers.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

extension String {
    public var trimmingWhitespaceOnEnds: String {
        var output = ""
        var pending = ""
        var foundNonWhitespace = false
        for char in self {
            switch char {
            case "\n", "\t", " ", "\r":
                if foundNonWhitespace {
                    pending.append(char)
                }
                else {
                    continue
                }
            default:
                foundNonWhitespace = true
                if !pending.isEmpty {
                    output += pending
                    pending = ""
                }
                output.append(char)
            }
        }
        return output
    }
}
