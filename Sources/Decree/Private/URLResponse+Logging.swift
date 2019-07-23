//
//  URLResponse+Logging.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/23/19.
//

import Foundation

extension URLResponse {
    var logDescription: String {
        var log = ""

        if let response = self as? HTTPURLResponse {
            let status = HTTPStatus(rawValue: response.statusCode)
            log += """
                \(response.statusCode) \(status)
                \(response.headers)
                """
        }

        return log
    }
}

private extension HTTPURLResponse {
    var headers: String {
        return self.allHeaderFields.map({ key, value in
            return "\(key): \(value)"
        }).joined(separator: "\n")
    }
}
