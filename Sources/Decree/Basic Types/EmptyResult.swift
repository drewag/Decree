//
//  EmptyResult.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/20/19.
//

import Foundation

/// Result type for endpoints without any output
public enum EmptyResult {
    case success
    case failure(DecreeError)

    public var error: DecreeError? {
        switch self {
        case .failure(let error):
            return error
        case .success:
            return nil
        }
    }
}
