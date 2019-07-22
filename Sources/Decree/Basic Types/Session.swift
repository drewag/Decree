//
//  Session.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/20/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

public protocol Session {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: Session {}
