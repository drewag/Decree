//
//  TestMinimalService.swift
//  DecreeTests
//
//  Created by Andrew Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation
import Decree

struct TestMinimalService: WebService {
    typealias BasicResponse = NoBasicResponse
    typealias ErrorResponse = NoErrorResponse

    static let shared = TestMinimalService()
    let sessionOverride: Session? = TestURLSession.test

    let baseURL = URL(string: "https://example.com")!
}

struct MinimalInOut: InOutEndpoint {
    typealias Service = TestMinimalService

    typealias Input = TestInput
    typealias Output = TestOutput

    let path = "minimal"
}
