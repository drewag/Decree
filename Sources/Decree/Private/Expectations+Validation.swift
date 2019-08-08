//
//  Expectations+Validation.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/7/19.
//

import Foundation

extension AnyExpectation {
    func valuePathDifferentBetween(_ lhs: Any, and rhs: Any, path: String) -> String? {
        if let lhs = lhs as? [String:Any] {
            guard let rhs = rhs as? [String:Any] else {
                return path
            }
            return self.valuePathDifferentBetween(lhs, and: rhs, path: path)
        }

        if let lhs = lhs as? [Any] {
            guard let rhs = rhs as? [Any] else {
                return path
            }
            return self.valuePathDifferentBetween(lhs, and: rhs, path: path)
        }

        if let lhs = lhs as? String {
            guard let rhs = rhs as? String
                , rhs == lhs
                else
            {
                return path
            }
            return nil
        }

        if let lhs = lhs as? NSNumber {
            guard let rhs = rhs as? NSNumber
                , rhs == lhs
                else
            {
                return path
            }
            return nil
        }

        if let _ = lhs as? NSNull {
            guard let _ = rhs as? NSNull else {
                return path
            }
            return nil
        }

        return path
    }

    func valuePathDifferentBetween(_ lhs: [String:Any], and rhs: [String:Any], path: String) -> String? {
        guard lhs.count == rhs.count else {
            return path
        }

        let lKeys = lhs.keys.sorted()

        for key in lKeys {
            let newPath = path + (path.isEmpty ? "" : ".") + "\(key)"
            let left = lhs[key]!
            guard let right = rhs[key] else {
                return newPath
            }
            if let path = self.valuePathDifferentBetween(left, and: right, path: newPath) {
                return path
            }
        }

        return nil
    }

    func valuePathDifferentBetween(_ lhs: [Any], and rhs: [Any], path: String) -> String? {
        guard lhs.count == rhs.count else {
            return path
        }

        for index in 0 ..< lhs.count {
            let newPath = path + (path.isEmpty ? "" : ".") + "\(index)"
            if let path = self.valuePathDifferentBetween(lhs[index], and: rhs[index], path: newPath) {
                return path
            }
        }

        return nil
    }
}
