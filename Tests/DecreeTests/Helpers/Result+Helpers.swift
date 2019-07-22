//
//  Result+Helpers.swift
//  DecreeTests
//
//  Created by Andrew J Wagner on 7/21/19.
//  Copyright © 2019 Drewag. All rights reserved.
//

import Foundation

extension Result {
    var error: Failure? {
        switch self {
        case .failure(let failure):
            return failure
        case .success:
            return nil
        }
    }

    var output: Success? {
        switch self {
        case .failure:
            return nil
        case .success(let success):
            return success
        }
    }
}
