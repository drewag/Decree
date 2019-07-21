//
//  AuthorizationRequirement.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

public enum AuthorizationRequirement {
    // Never include authorization
    case none

    // Include authorization if present
    case optional

    // Create error if not authorized
    case required
}
