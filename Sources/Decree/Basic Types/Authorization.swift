//
//  Authentication.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

/// Authorization for requests
public enum Authorization {
    /// Not authorized
    case none

    /// [Basic Auth](https://en.wikipedia.org/wiki/Basic_access_authentication)
    case basic(username: String, password: String)

    /// [Bearer Auth](https://swagger.io/docs/specification/authentication/bearer-authentication)
    case bearer(base64Token: String)

    /// Define a custom [HTTP header](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields) for authorization
    ///
    /// - Parameters:
    ///     - key: the HTTP header key
    ///     - value: the HTTP header value
    case custom(key: String, value: String)
}
