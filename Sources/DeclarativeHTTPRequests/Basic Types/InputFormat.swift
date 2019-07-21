//
//  InputFormat.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//

/// Format for uploading data to endpoint
public enum InputFormat {
    case JSON
    case XML(rootNode: String)
    case urlQuery
    case formURLEncoded
}
