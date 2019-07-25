//
//  String+TitleCase.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/24/19.
//

import Foundation

extension String {
    var titleCased: String {
        return self.components(separatedBy: " ")
            .map({ word in
                switch word {
                case "a", "an", "the", "to":
                    return word
                default:
                    return word.capitalized(with: Locale.current)
                }
            })
            .joined(separator: " ")
    }
}
