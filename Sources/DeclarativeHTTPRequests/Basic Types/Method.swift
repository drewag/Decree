//
//  Method.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

/// HTTP Method for making requests
public enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case options = "OPTIONS"
    case patch = "PATCH"
}
