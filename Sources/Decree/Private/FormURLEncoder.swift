//
//  FormURLEncoder.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

struct FormURLEncoder {
    static func encode(_ data: [(String,KeyValueEncoder.Value)]) -> String {
        var output = ""

        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        func escape(_ string: String) -> String {
            return string.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
        }

        for (key, value) in data {
            if !output.isEmpty {
                output += "&"
            }
            output += "\(escape(key))="
            switch value {
            case .none:
                break
            case .string(let string):
                output += escape(string)
            case .data(let data):
                output += escape(data.base64EncodedString())
            case .bool(let bool):
                output += bool ? "true" : "false"
            case .file(let file):
                output += escape(file.content.base64EncodedString())
            }
        }

        return output
    }
}
