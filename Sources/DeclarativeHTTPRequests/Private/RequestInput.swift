//
//  RequestInput.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

enum RequestInput {
    case none
    case json(Data)
    case xml(Data)
    case formURLEncoded(Data)
    case urlQuery([URLQueryItem])
}
