//
//  DispatchQueue+Async.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/5/19.
//

import Foundation

extension Optional where Wrapped == DispatchQueue {
    func async(execute: @escaping () -> ()) {
        if let queue = self {
            queue.async(execute: execute)
        }
        else {
            execute()
        }
    }
}
