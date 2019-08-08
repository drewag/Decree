//
//  Logger.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/23/19.
//

import Foundation

/// Logger to control the printing of diagnostic information
///
/// The log level defaults to *none* which won't print out anything.
///
/// Change the log level to *info* to log out raw requests and responses
/// with the option to specify a filter to only print out particular
/// endpoints
public struct Logger {
    public static var shared = Logger()

    public enum Level {
        /// Log nothing
        case none

        /// Log requests and responses
        ///
        /// Optional filter to only log out certain Endpoints in format <Service>[.<RequestName>]
        /// e.g. "MyService" or "MyService.Endpoint1" for just Endpoint1 in MyService
        case info(filter: String?)
    }

    /// What level of logging is enabled
    public var level = Level.none

    var logToMemory: Bool = false
    var logs = [String]()

    mutating func logInfo<E: Endpoint>(_ string: @autoclosure () -> String, for endpoint: E) {
        switch self.level {
        case .none:
            break
        case .info(let filter):
            guard endpoint.matches(filter: filter) else {
                break
            }

            let string = string()
            if self.logToMemory {
                self.logs.append(string)
            }
            else {
                print(string)
            }
        }
    }
}

private extension Endpoint {
    func matches(filter: String?) -> Bool {
        guard let filter = filter else {
            return true
        }

        let components = filter.components(separatedBy: ".")
        switch components.count {
        case 1:
            return "\(Service.self)" == filter
        case 2:
            return "\(Service.self)" == components[0] && "\(Self.self)" == components[1]
        default:
            return true
        }
    }
}
