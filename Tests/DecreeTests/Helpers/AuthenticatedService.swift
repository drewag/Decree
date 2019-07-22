//
//  AuthenticatedService.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation
import Decree

struct AuthenticatedService: WebService {
    typealias BasicResponse = NoBasicResponse
    typealias ErrorResponse = NoErrorResponse

    static var shared = AuthenticatedService()
    let sessionOverride: Session? = TestURLSession.test

    var authorization = Authorization.none

    let baseURL = URL(string: "https://example.com")!
}

struct NoAuthEmpty: EmptyEndpoint {
    typealias Service = AuthenticatedService

    let path = ""

    static let authorizationRequirement = AuthorizationRequirement.none
}

struct OptionalAuthEmpty: EmptyEndpoint {
    typealias Service = AuthenticatedService

    let path = ""

    static let authorizationRequirement = AuthorizationRequirement.optional
}

struct RequiredAuthEmpty: EmptyEndpoint {
    typealias Service = AuthenticatedService

    let path = ""

    static let authorizationRequirement = AuthorizationRequirement.required
}
