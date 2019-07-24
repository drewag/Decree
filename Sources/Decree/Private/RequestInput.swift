//
//  RequestInput.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

enum RequestInput {
    case none
    case json(Data)
    case xml(Data)
    case binary(Data)
    case plainText(Data)
    case formURLEncoded(Data)
    case formData(Data)
    case urlQuery([URLQueryItem])
}
