//
//  ErrorHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

public enum ErrorHandling {
    /// Propagate this error
    case error(DecreeError)

    /// Repeat the exact same request to the new URL provided
    case redirect(to: URL)
}
