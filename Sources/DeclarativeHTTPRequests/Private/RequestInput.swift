//
//  RequestInput.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

enum RequestInput {
    case none
    case body(Data)
    case urlQuery([URLQueryItem])
}
