//
//  DecreeErrorDescribable.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/6/19.
//

/// Protocol to improve the reporting of your own errors
protocol DecreeErrorDescribable {
    var reason: String {get}
    var details: String? {get}
    var isInternal: Bool {get}
}
