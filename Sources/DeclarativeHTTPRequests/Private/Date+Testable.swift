//
//  Date+Testable.swift
//  DeclarativeHTTPRequests
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

private var faked: (base: Date, started: Date)?

extension Date {
    static func startFakingNow(from: Date) {
        faked = (from, Date())
    }

    static func stopFakingNow() {
        faked = nil
    }

    static func addFake(interval: TimeInterval) {
        if faked == nil {
            self.startFakingNow(from: Date())
        }
        if let old = faked {
            faked = (old.base.addingTimeInterval(interval), started: old.started)
        }
    }

    static var now: Date {
        guard let faked = faked else {
            return Date()
        }
        let interval = Date().timeIntervalSince(faked.started)
        return faked.base.addingTimeInterval(interval)
    }
}
