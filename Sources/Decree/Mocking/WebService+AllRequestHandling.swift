//
//  WebService+AllRequestHandling.swift
//  Decree
//
//  Created by Andrew J Wagner on 8/6/19.
//

import Foundation

extension WebService {
    /// Closure to manually handle web service request
    public typealias AllRequestsHandler = (URLRequest) -> (Data?, URLResponse?, Error?)

    public static func startHandlingAllRequests(handler: @escaping AllRequestsHandler) {
        self.stopHandlingAllRequests()

        AllRequestsHandlers.append((service: self, handler: handler))
    }

    public static func stopHandlingAllRequests() {
        let index = AllRequestsHandlers.firstIndex(where: { spec in
            return spec.service is Self.Type
        })

        guard let actualIndex = index else {
            return
        }
        AllRequestsHandlers.remove(at: actualIndex)
    }
}
