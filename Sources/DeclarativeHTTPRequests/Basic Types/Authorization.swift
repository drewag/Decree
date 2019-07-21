//
//  Authentication.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

public enum Authorization {
    case none
    case basic(username: String, password: String)
    case bearer(base64Token: String)
    case custom(key: String, value: String)
}
