//
//  ErrorHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 7/22/19.
//

import Foundation

public enum ErrorHandling {
    /// Do nothing, propagate the error up to the requester
    case none

    /// Repeat the exact same request to the new URL provided
    case redirect(to: URL)
}
