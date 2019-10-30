//
//  URLRequest+Logging.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/23/19.
//

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLRequest {
    var logDescription: String {
        var log = """
            \(self.basicLog)
            \(self.headers)
            """

        if let body = self.bodyLog {
            log += "\n" + body
        }

        return log
    }
}

private extension URLRequest {
    var basicLog: String {
        return "\(self.httpMethod ?? "GET") \(url?.absoluteString ?? "NO URL")"
    }

    var headers: String {
        return (self.allHTTPHeaderFields ?? [:]).map({ key, value in
            return "\(key): \(value)"
        }).sorted().joined(separator: "\n")
    }

    var bodyLog: String? {
        guard let data = self.httpBody else {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            return "\n\(data)"
        }
        return "\n\(string)"
    }
}
