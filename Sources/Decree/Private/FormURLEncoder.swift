//
//  FormURLEncoder.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

struct FormURLEncoder {
    public static func encode(_ data: [(String,String?)]) -> String {
        var output = ""

        let characterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        func escape(_ string: String) -> String {
            return string.addingPercentEncoding(withAllowedCharacters: characterSet) ?? ""
        }

        for (key, value) in data {
            if !output.isEmpty {
                output += "&"
            }
            if let value = value {
                output += "\(escape(key))=\(escape(value))"
            }
            else {
                output += "\(escape(key))="
            }
        }

        return output
    }
}
