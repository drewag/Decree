//
//  Date+Testable.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

private var faked: (base: Date, started: Date)?

extension Date {
    public static func startFakingNow(from: Date) {
        faked = (from, Date())
    }

    public static func stopFakingNow() {
        faked = nil
    }

    public static func addFake(interval: TimeInterval) {
        if faked == nil {
            self.startFakingNow(from: Date())
        }
        if let old = faked {
            faked = (old.base.addingTimeInterval(interval), started: old.started)
        }
    }

    public static var now: Date {
        guard let faked = faked else {
            return Date()
        }
        let interval = Date().timeIntervalSince(faked.started)
        return faked.base.addingTimeInterval(interval)
    }
}
